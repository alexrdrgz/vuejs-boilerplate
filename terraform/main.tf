provider "aws" {
  profile = "default"
  region  = "us-west-2"
}

provider "aws" {
  alias  = "cloudfront_aws"
  region = "us-east-1"
}

terraform {
  backend "s3" {
    bucket = "alex-rodriguez-tfstate"
    key    = "frontend-boilerplate/terraform.tfstate"
    region = "us-west-2"
  }
}


