terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.55"
    }
  }
  backend s3 {
    region = "ap-northeast-1"
    bucket = "masol-stg-terraform-state-3"
    key = "state/terraform.state"
    profile = "masol-test-2"
  }
}

provider "aws" {
  region = "ap-northeast-1"
  profile = "masol-test-2"

  default_tags {
    tags = local.tags
  }
}

