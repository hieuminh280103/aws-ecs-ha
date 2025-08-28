variable "vpc_cidr" {
  type = string
  default = "10.10.0.0/16"
}

variable "vpc_public_subnets" {
  default = ["10.10.1.0/24", "10.10.2.0/24"]
}

variable "vpc_private_subnets" {
  default = ["10.10.3.0/24", "10.10.4.0/24"]
}

variable "vpc_database_subnets" {
  default = ["10.10.5.0/24", "10.10.6.0/24"]
}

variable "vpc_azs" {
  default = ["ap-northeast-1a", "ap-northeast-1d"]
}

variable "enable_flow_log" {
  default = false
}

variable "flow_log_cloudwatch_group_retention_in_days" {
  default = 60
}

variable "enable_nat_gateway" {
  default = false
}

variable "dedicated_network_acl" {
  default = true
}