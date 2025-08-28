variable "project" {
  default = "masol"
}
variable "environment" {
  default = "stg"
}
variable "create_by" {
  default = "Terraform"
}
variable "region" {
  default = "ap-northeast-1"
}

# #ARN cert ARM Tokyo
# variable "acm_certificate_arn" {
#   type = string
# }
# variable "acm_certificate_arn_global" {
#   type = string
#   # region US East (N. Virginia)
# }

variable "email_sub" {
  type = string
}

variable "key_pem" {
  default = "masol-stg"
}
variable "logs_retention_day" {
  default = 90
}

variable "kms_key_id" {
#   default     = "alias/aws/sqs"
    default = null
}
variable "cache_optimzied_id" {
  default = "658327ea-f89d-4fab-a63d-7e88639e58f6" //cache optimized for S3
}

# variable "cache_disabled" {
#   default = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad"
# }

variable "ConnectionArn" {
  default = "arn:aws:codestar-connections:ap-northeast-1:891377085045:connection/8acafec3-f8c2-4d88-a117-5ad75214b8e5"
}

# variable "Managed_CORS_S3Origin" {
#   default = "88a5eaf4-2fd4-4709-b370-b4c650ea3fcf"
# }
# variable "prefix_list_ids_CF" {
#   default = "pl-58a04531"
# }

# variable "cors-policy" {
#   default = "fb07fa2f-5970-4034-aab5-58b0b804e853"
# }
variable "origin_access_control_id" {
  default = "216adef6-5c7f-47e4-b989-5492eafa07d3" // Managed all Viewer- recommend for alb orgin
}