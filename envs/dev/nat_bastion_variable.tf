

variable "nat_bastion_instance_type" {
  default = "t3a.nano"
}

variable "nat_bastion_ami" {
  default = "ami-007add8d6b8a5fb81"
}

variable "singed_nat_gateway" {
  default = false
}

variable "nat_ip_destination" {
  description = "The next hop of nat"
  default     = ["0.0.0.0/0"]
  type        = list(string)
}
variable "nat_instance_allow_rule" {
  type = list(object({
    cidr_block  = list(string)
    from_port   = number
    to_port     = number
    description = string
  }))
  default = [
    {
      cidr_block  = ["27.72.98.245/32"]
      from_port   = 22
      to_port     = 22
      description = "Allow ssh from dev"
    },
    {
      cidr_block  = ["221.133.18.67/32"]
      from_port   = 22
      to_port     = 22
      description = "Allow ssh from dev"
    },
    {
      cidr_block  = ["118.71.249.60/32"]
      from_port   = 22
      to_port     = 22
      description = "Allow ssh from dev"
    },
    {
      cidr_block  = ["10.10.0.0/16"]
      from_port   = 0
      to_port     = 65535
      description = "Allow all from VPC"
    },
  ]
}
