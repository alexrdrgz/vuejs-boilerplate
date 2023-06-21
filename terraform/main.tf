provider "aws" {
  profile    = "default"
  region     = "us-west-2"
  access_key = var.access_key
  secret_key = var.secret_key
}

provider "aws" {
  alias      = "cloudfront_aws"
  region     = "us-east-1"
  access_key = var.access_key
  secret_key = var.secret_key
}

terraform {
  backend "s3" {
    bucket = "alex-rodriguez-tfstate"
    key    = "frontend-boilerplate/terraform.tfstate"
    region = "us-west-2"
  }
}

data "aws_route53_zone" "zone" {
  name         = var.route53_zone
  private_zone = false
}

resource "aws_cloudfront_response_headers_policy" "security_headers_policy" {
  name  = "security-headers-policy"

  security_headers_config {
    content_type_options {
      override = true
    }
    frame_options {
      frame_option = "DENY"
      override     = true
    }
    referrer_policy {
      referrer_policy = "same-origin"
      override        = true
    }
    xss_protection {
      mode_block = true
      protection = true
      override   = true
    }
    strict_transport_security {
      access_control_max_age_sec = "63072000"
      include_subdomains         = true
      preload                    = true
      override                   = true
    }
    content_security_policy {
      content_security_policy = "frame-ancestors 'none'; default-src 'none'; img-src 'self'; script-src 'self'; style-src 'self'; object-src 'none'"
      override                = true
    }
  }
}

resource "aws_acm_certificate" "cloudfront_cert" {
  provider                  = aws.cloudfront_aws
  domain_name               = var.domain_name
  subject_alternative_names = ["www.${var.domain_name}"]
  validation_method         = "DNS"
}

resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.cloudfront_cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.zone.id
}

resource "aws_s3_bucket" "web_bucket" {
  bucket = var.domain_name
}

resource "aws_s3_bucket_public_access_block" "bucket_acl_allow" {
  bucket = aws_s3_bucket.web_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}


resource "aws_s3_bucket_ownership_controls" "bucket_owner" {
  bucket = aws_s3_bucket.web_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "web_bucket" {
  depends_on = [
    aws_s3_bucket_public_access_block.bucket_acl_allow,
    aws_s3_bucket_ownership_controls.bucket_owner
  ]

  bucket = aws_s3_bucket.web_bucket.id
  acl    = "public-read"
}


resource "aws_s3_bucket_policy" "web_bucket" {
  depends_on = [aws_s3_bucket_ownership_controls.bucket_owner]
  
  bucket     = aws_s3_bucket.web_bucket.id
  policy     = <<EOF
{
    "Version": "2008-10-17",
    "Statement": [
    {
        "Sid": "PublicReadForGetBucketObjects",
        "Effect": "Allow",
        "Principal": {
            "AWS": "*"
         },
         "Action": "s3:GetObject",
         "Resource": "arn:aws:s3:::${var.domain_name}/*"
    }]
}
EOF
}

# Create Cloudfront distribution
resource "aws_cloudfront_distribution" "prod_distribution" {
  origin {
    domain_name = aws_s3_bucket.web_bucket.bucket_domain_name
    origin_id   = "S3-${aws_s3_bucket.web_bucket.bucket}"
  }

  aliases = [var.domain_name, "www.${var.domain_name}"]

  depends_on = [aws_route53_record.cert_validation]

  # By default, show index.html file
  default_root_object = "index.html"
  enabled             = true

  # If there is a 404, return index.html with a HTTP 200 Response
  custom_error_response {
    error_caching_min_ttl = 3000
    error_code            = 404
    response_code         = 200
    response_page_path    = "/index.html"
  }

  default_cache_behavior {
    response_headers_policy_id = aws_cloudfront_response_headers_policy.security_headers_policy.id 
    allowed_methods            = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods             = ["GET", "HEAD"]
    target_origin_id           = "S3-${aws_s3_bucket.web_bucket.bucket}"

    # Forward all query strings, cookies and headers
    forwarded_values {
      query_string = true

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  # Cache behavior with precedence 0
  ordered_cache_behavior {
    response_headers_policy_id = aws_cloudfront_response_headers_policy.security_headers_policy.id
    path_pattern               = "index.html"
    allowed_methods            = ["GET", "HEAD", "OPTIONS"]
    cached_methods             = ["GET", "HEAD", "OPTIONS"]
    target_origin_id           = "S3-${aws_s3_bucket.web_bucket.bucket}"

    forwarded_values {
      query_string = false
      headers      = ["Origin"]

      cookies {
        forward = "none"
      }
    }

    min_ttl                = 0
    default_ttl            = 0
    max_ttl                = 0
    compress               = true
    viewer_protocol_policy = "redirect-to-https"
  }

  # Distributes content to US and Europe
  price_class = "PriceClass_100"

  # Restricts who is able to access this content
  restrictions {
    geo_restriction {
      # type of restriction, blacklist, whitelist or none
      restriction_type = "none"
    }
  }

  # SSL certificate for the service.
  viewer_certificate {
    acm_certificate_arn = aws_acm_certificate.cloudfront_cert.arn
    ssl_support_method  = "sni-only"
  }

}

# Create Route 53
resource "aws_route53_record" "cloud_front" {
  zone_id = data.aws_route53_zone.zone.id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.prod_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.prod_distribution.hosted_zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "cloud_front_www" {
  zone_id = data.aws_route53_zone.zone.id
  name    = "www.${var.domain_name}"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.prod_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.prod_distribution.hosted_zone_id
    evaluate_target_health = true
  }
}