data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
data "aws_ami" "ec2_amzn2_x86" {

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*"]
  }
  filter {
      name = "architecture"
      values = ["x86_64"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["amazon"]
  most_recent = true
}