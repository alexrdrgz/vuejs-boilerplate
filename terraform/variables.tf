variable "domain_name" {
  type        = string
  description = "The domain name for the site"
}

variable "route53_zone" {
  type = string
  description = "the name of the domain that you have purchased on aws route53"
}

variable "access_key" {
  type = string
  description = ""
}

variable "secret_key" {
  type = string
}
