resource "aws_security_group" "this" {
  name_prefix = var.name
  vpc_id      = var.vpc_id
  description = "Security group for NAT instance ${var.name}"
  ## Ingress Rule
  dynamic "ingress" {
    for_each         = var.nat_instance_allow_rule
    content {
      description      = format("%s", ingress.value["description"])
      from_port        = ingress.value["from_port"]
      to_port          = ingress.value["to_port"]
      protocol         = "tcp"
      cidr_blocks      = ingress.value["cidr_block"]
      ipv6_cidr_blocks = []
      prefix_list_ids = []
      security_groups = []
      self = false
    }
  }
  egress = [
    {
      description = "ALLOW ALL"
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
      prefix_list_ids = []
      security_groups = []
      self = false
    }
  ]
  tags        = local.common_tags
}

#resource "aws_security_group_rule" "egress" {
#  security_group_id = aws_security_group.this.id
#  type              = "egress"
#  cidr_blocks       = ["0.0.0.0/0"]
#  from_port         = 0
#  to_port           = 0
#  protocol          = "-1"
#}
#
# resource "aws_security_group_rule" "ingress_all_from_vpc" {
#  security_group_id = aws_security_group.this.id
#  type              = "ingress"
#  cidr_blocks       = ["${var.allow_all_from_vpc}"]
#  from_port         = 0
#  to_port           = 0
#  protocol          = "-1"
# }

resource "aws_network_interface" "this" {
  security_groups   = [aws_security_group.this.id]
  subnet_id         = var.public_subnet
  source_dest_check = false
  description       = "ENI for NAT instance ${var.name}"
  tags              = local.common_tags
}

module "aws_route" {
  source = "./fix_destroy_route"

  count = length(var.nat_ip_destination)

  private_route_table_ids = var.private_route_table_ids
  nat_ip_destination = var.nat_ip_destination[count.index]
  network_interface_id = aws_network_interface.this.id
}

resource "aws_instance" "this" {
  ami                  = var.image_id
  key_name             = var.key_name
  iam_instance_profile = aws_iam_instance_profile.this.name
  instance_type        = var.instance_type
  root_block_device {
    volume_size           = 8
    volume_type           = "gp3"
    delete_on_termination = true
  }
  network_interface {
    network_interface_id = aws_network_interface.this.id
    device_index         = 0
  }
  volume_tags = merge(
    {
      Name = var.name
    },
    local.common_tags
  )
  user_data = base64encode(join("\n", [
    "#cloud-config",
    yamlencode({
      # https://cloudinit.readthedocs.io/en/latest/topics/modules.html
      write_files : concat([
        {
          path : "/opt/nat/runonce.sh",
          content : templatefile("${path.module}/runonce.sh", { eni_id = aws_network_interface.this.id }),
          permissions : "0755",
        }
      ], var.user_data_write_files),
      runcmd : concat([
        ["/opt/nat/runonce.sh"],
      ], var.user_data_runcmd),
    })
  ]))

  tags = merge(
    {
      Name = var.name
    },
    local.common_tags
  )
}

resource "aws_iam_instance_profile" "this" {
  name_prefix = var.name
  role        = aws_iam_role.this.name
}

resource "aws_iam_role" "this" {
  name_prefix        = var.name
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

  tags = local.common_tags
}

resource "aws_iam_role_policy_attachment" "ssm" {
  policy_arn = var.ssm_policy_arn
  role       = aws_iam_role.this.name
}
