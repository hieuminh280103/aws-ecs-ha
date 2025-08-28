//cloudfront dns
variable "admin_frontend_domain" {
  type = string
  default ="dev-manage-api.masol.com"
}
variable "admin_api_domain" {
  default = "dev-manage.masol.com"
}
variable "files_domain" {
  default = "dev-files.masol.com"
}

variable "private_domain" {
  default = "masol.internal"
}

variable "redis_domain" {
  default = "stg-redis.masol.internal"
}