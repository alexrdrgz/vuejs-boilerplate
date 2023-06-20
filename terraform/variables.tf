variable "domain_name" {
  type        = string
  description = "The domain name for the site"
}

variable "bucket_name" {
  type        = string
  description = "The name of the bucket"
}

variable "route53_zone" {
  type = string
}

variable "access_key" {
  type = string
}

variable "secret_key" {
  type = string
}
