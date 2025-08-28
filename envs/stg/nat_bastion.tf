module "nat-bastion" {
  source   = "../../modules/nat-instance-module/nat-instance"
  name     = "${local.name_prefix}-nat-bastion"
  key_name = var.key_pem
  vpc_id   = module.vpc.vpc_id
  # image_id                    = data.aws_ami.ec2_amzn2_x86.id
  image_id                    = var.nat_bastion_ami
  instance_type               = var.nat_bastion_instance_type
  public_subnet               = module.vpc.public_subnets[0]
  private_subnets_cidr_blocks = local.combined_private_subnets_cidr_blocks
  private_route_table_ids     = local.combined_private_route_table_ids
  nat_ip_destination          = var.nat_ip_destination
  nat_instance_allow_rule     = var.nat_instance_allow_rule
  tags                        = local.tags
}
#assign eip to nat
resource "aws_eip" "nat-bastion" {
  network_interface = module.nat-bastion.eni_id

  tags = merge(
    {
      Name = "${local.name_prefix}-nat-instance-eip-1"
    },
    local.tags
  )
  depends_on = [
    module.nat-bastion
  ]
}
