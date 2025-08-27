variable "project" {}
variable "environment" {}
variable "service_name" {}
variable "codebuild_role_name" {
    default = null
}
variable "codebuild_policy" {
    default = {}
}
variable "tags" {
    default = {}
}
variable "log_retention_in_days" {}

variable "vpc_id" {
    default = null
}
variable "private_subnet_ids" {
  default = []
}

variable "secrets_manager" {
  default = []
}

variable "use_secrets_manager" {
  default = true
}

variable "codebuild_build_timeout" { default = 1 }
variable "codebuild_queued_timeout" { default = 1 }
variable "codebuild_compute_type" { default = "BUILD_GENERAL1_SMALL" }
variable "codebuild_image" { default = "aws/codebuild/standard:4.0" }
variable "codebuild_type" { default = "LINUX_CONTAINER" }
variable "codebuild_image_pull_credentials_type" { default = "CODEBUILD" }
variable "codebuild_privileged_mode" { default = true }

variable "codebuild_environment_variable" { default = {} }
variable "codebuild_buildspec" { default = "buildspec.yaml" }
variable "codepipeline_artifact_bucket" { default = [] }

variable "in_vpc" {
  default = true
}
variable "create_codebuild_role" {
  default = true
}
variable "codebuild_fe" {
  default = true
}
variable "cloudfront_distribution" {
  default = "true"
}
variable "s3_frontend_bucket" {
  default = ""
}