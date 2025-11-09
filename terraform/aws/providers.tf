terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.20.0"
    }
  }
}

provider "aws" {
  shared_config_files      = ["/home/marcus/.aws/config"]
  shared_credentials_files = ["/home/marcus/.aws/credentials"]
  profile                  = "personal"
  region                   = "us-east-2"

  default_tags {
    tags = {
      Terraform = "true"
    }
  }
}
