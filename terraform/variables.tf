variable "domain_name" {
  type        = string
  description = "The domain name for the site, this can be a root domain or subdomain"
}

variable "route53_zone" {
  type = string
  description = "the name of the domain that you have purchased on aws route53, should just be something like example.com"
}

variable "access_key" {
  type = string
  description = "access key you create for your aws user"
}

variable "secret_key" {
  type = string
  description = "secret key you create for your aws user"
}
