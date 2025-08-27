#APPROVE
variable "manual_approve_comment" {
  default = "Application deploy waiting manually approval!"
}

variable "admin_backend" {
  default = {
    FullRepositoryId = "Hung-TM/books"
    default_branch   = "main"
  }
}

variable "admin_frontend" {
  default = {
    FullRepositoryId = "Hung-TM/books"
    default_branch   = "main"
  }
}

##Service name

variable "admin_frontend_service_name" {
  default = "admin-frontend"
}

variable "admin_backend_service_name" {
  default = "admin-backend"
}
## Frontend
variable "codebuild_frontend" {
  default = {
    build_timeout               = 480
    queued_timeout              = 480
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:6.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = true
    log_retention_in_days       = 30
  }
}

## Backend

variable "codebuild_backend" {
  default = {
    build_timeout               = 480
    queued_timeout              = 480
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:6.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = true
    log_retention_in_days       = 30
  }
}
