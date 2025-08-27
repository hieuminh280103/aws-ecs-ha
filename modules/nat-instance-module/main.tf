module "vpc" {
  source = "./vpc"

  name = "${local.name_prefix}-vpc"
  cidr = var.vpc_cird
  azs = var.availability_zones

  private_subnets = var.private_subnets
  public_subnets = var.public_subnets

  manage_default_route_table = true
  default_route_table_tags   = { DefaultRouteTable = true }

  enable_dns_hostnames = true
  enable_dns_support   = true

  enable_nat_gateway = false
  single_nat_gateway = var.single_nat_gateway

  # Default security group - ingress/egress rules cleared to deny all
  manage_default_security_group  = true
  default_security_group_ingress = []
  default_security_group_egress  = []

  # VPC Flow Logs (Cloudwatch log group and IAM role will be created)
  enable_flow_log                      = false
  create_flow_log_cloudwatch_log_group = false
  create_flow_log_cloudwatch_iam_role  = false
  flow_log_max_aggregation_interval    = 60

  create_database_subnet_route_table = false
  database_dedicated_network_acl = false
  database_inbound_acl_rules = var.network_acl_database_inbound
  database_outbound_acl_rules = var.network_acl_database_outbound

  map_public_ip_on_launch = false

  public_dedicated_network_acl = true
  public_outbound_acl_rules = var.network_acl_private_outbound
  public_inbound_acl_rules = var.network_acl_private_inbound

  private_dedicated_network_acl = true

  database_subnet_group_name = "${local.name_prefix}-database-subnet"

  tags = local.tags
}

module "nat_instance" {
  source = "./nat-instance"

  name                        = "${local.name_prefix}-nat-instance"
  key_name                    = var.nat_server_key
  vpc_id                      = module.vpc.vpc_id
  public_subnet               = module.vpc.public_subnets[0]
  private_subnets_cidr_blocks = module.vpc.private_subnets_cidr_blocks
  private_route_table_ids     = module.vpc.private_route_table_ids
  instance_type               = var.nat_server_type
  image_id                    = data.aws_ami.ec2_amzn2_x86.id
  nat_ip_destination          = var.nat_ip_destination
  nat_instance_allow_rule     = var.nat_instance_allow_rule
  tags                        = local.tags
}

resource "aws_eip" "nat_instance" {
  network_interface = module.nat_instance.eni_id

  tags = merge(
    {
      Name = "${local.name_prefix}-nat-instance-eip-1"
    },
    local.tags
  )
  depends_on = [
    module.nat_instance
  ]
}
