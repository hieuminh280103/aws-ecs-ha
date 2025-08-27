variable "enabled" {
  description = "Enable or not costly resources"
  type        = bool
  default     = true
}

variable "name" {
  description = "Name for all the resources as identifier"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "public_subnet" {
  description = "ID of the public subnet to place the NAT instance"
  type        = string
}

variable "private_subnets_cidr_blocks" {
  description = "List of CIDR blocks of the private subnets. The NAT instance accepts connections from this subnets"
  type        = list(string)
}

variable "private_route_table_ids" {
  description = "List of ID of the route tables for the private subnets. You can set this to assign the each default route to the NAT instance"
  type        = list(string)
  default     = []
}

variable "image_id" {
  description = "AMI of the NAT instance. Default to the amzn-ami-vpc-nat-2018.03.0.20220503.0-x86_64-ebs"
  type        = string
}

variable "instance_type" {
  description = "Candidates of spot instance type for the NAT instance. This is used in the mixed instances policy"
  type        = string
}

variable "nat_ip_destination" {
  description = "The next hop of nat"
  default     = ["52.221.172.238/32"] #Jira server IP
  type        = list(string)
}

variable "user_data_write_files" {
  description = "Additional write_files section of cloud-init"
  type        = list(any)
  default     = []
}

variable "user_data_runcmd" {
  description = "Additional runcmd section of cloud-init"
  type        = list(list(string))
  default     = []
}

variable "key_name" {
  description = "Name of the key pair for the NAT instance. You can set this to assign the key pair to the NAT instance"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags applied to resources created with this module"
  type        = map(string)
  default     = {}
}

locals {
  // Merge the default tags and user-specified tags.
  // User-specified tags take precedence over the default.
  common_tags = merge(
    {
      Name = "${var.name}"
    },
    var.tags,
  )
}

variable "ssm_policy_arn" {
  description = "SSM Policy to be attached to instance profile"
  type        = string
  default     = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}


variable "user_data" {
  description = "The user data to provide when launching the instance. Do not pass gzip-compressed data via this argument; see user_data_base64 instead."
  type        = string
  default     = null
}

variable "user_data_base64" {
  description = "Can be used instead of user_data to pass base64-encoded binary data directly. Use this instead of user_data whenever the value is not a valid UTF-8 string. For example, gzip-encoded user data must be base64-encoded and passed via this argument to avoid corruption."
  type        = string
  default     = null
}

variable "user_data_replace_on_change" {
  description = "When used in combination with user_data or user_data_base64 will trigger a destroy and recreate when set to true. Defaults to false if not set."
  type        = bool
  default     = false
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
      cidr_block  = ["0.0.0.0/0"]
      from_port   = 0
      to_port     = 65535
      description = "Allow All Traffic from any where"
    }
  ]
}

variable "allow_all_from_vpc" {
  default = []
}