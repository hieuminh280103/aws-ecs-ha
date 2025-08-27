//cloudfront dns
variable "admin_frontend_domain" {
  type = string
  default ="dev-manage-api.example.com"
}
variable "admin_api_domain" {
  default = "dev-manage.example.com"
}
variable "files_domain" {
  default = "dev-files.example.com"
}

variable "private_domain" {
  default = "domain.internal"
}

variable "db_writer_domain" {
  default = "dev-db-writer.domain.internal"
}

variable "db_reader_domain" {
  default = "dev-db-reader.domain.internal"
}
variable "redis_domain" {
  default = "dev-redis.domain.internal"
}