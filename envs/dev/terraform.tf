terraform {
  required_version = ">=0.13.1"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">=5.0"
    }
  }
#  backend "s3" {
#    bucket  = "project-dev-terraform"
#    key     = "base/main/terraform.state"
#    region  = "ap-northeast-1"
#    profile = "project-dev"
#    shared_credentials_files = ["~/.aws/credentials"]
#  }
}
provider "aws" {
  region = "ap-northeast-1"
  profile = "kaopiz-dev"
  shared_credentials_files = ["~/.aws/credentials"]
}

