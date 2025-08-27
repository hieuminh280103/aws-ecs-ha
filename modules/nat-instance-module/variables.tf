// VPC
variable "vpc_cird" {
    default = "10.61.0.0/16"
}
variable "public_subnets" {
    default = ["10.61.5.0/24", "10.61.6.0/24"]
}
variable "private_subnets" {
    default = ["10.61.1.0/24", "10.61.2.0/24"]
}
variable "database_subnets" {
    default = ["10.61.9.0/24", "10.61.10.0/24"]
}
variable "single_nat_gateway" {
    default = false
}
variable "availability_zones" {
  default = ["ap-northeast-1a", "ap-northeast-1c"]
}
variable "network_acl_public_outbound" {
    default = [
      {
        rule_number = 100
        rule_action = "allow"
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_block  = "0.0.0.0/0"
      }
    ]
}
variable "network_acl_public_inbound" {
    default = [
      {
        rule_number = 100
        rule_action = "allow"
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_block  = "0.0.0.0/0"
      }
    ]
}
variable "network_acl_private_outbound" {
    default = [
      {
        rule_number = 100
        rule_action = "allow"
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_block  = "0.0.0.0/0"
      }
    ]
}
variable "network_acl_private_inbound" {
    default = [
      {
        rule_number = 100
        rule_action = "allow"
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_block  = "0.0.0.0/0"
      }
    ]
}
variable "network_acl_database_outbound" {
    default = [
      {
        rule_number = 100
        rule_action = "allow"
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_block  = "0.0.0.0/0"
      }
    ]
}
variable "network_acl_database_inbound" {
    default = [
      {
        rule_number = 100
        rule_action = "allow"
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_block  = "0.0.0.0/0"
      }
    ]
}
## Nat Instance
variable "nat_server_key" {
  default = "tofasgi-ph-coding-nat-instance"
}
variable "nat_server_type" {
  default = "t3a.nano"
}
variable "nat_instance_server_ami" {
  default = "ami-0d20e3666350e2d67"
}
variable "nat_ip_destination" {
  description = "The next hop of nat"
  default     = ["0.0.0.0/0"]
  type        = list(string)
}
variable "nat_instance_allow_rule" {
  type = list(object({
    cidr_block = list(string)
    from_port   = number
    to_port     = number
    description = string
  }))
  default = [
    {
      cidr_block  = ["192.168.0.0/16"]
      from_port   = 0
      to_port     = 65535
      description = "ALL from Own VPC"
    }
  ]
}