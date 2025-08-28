  module "vpc" {
  source                  = "../../modules/terraform-aws-vpc"
  name                    = "${local.name_prefix}-vpc"
  cidr                    = var.vpc_cidr
  azs                     = var.vpc_azs
  public_subnets          = var.vpc_public_subnets
  private_subnets         = var.vpc_private_subnets
  database_subnets        = var.vpc_database_subnets
  map_public_ip_on_launch = true

  database_dedicated_network_acl = var.dedicated_network_acl
  private_dedicated_network_acl = var.dedicated_network_acl
  public_dedicated_network_acl = var.dedicated_network_acl


  manage_default_route_table = true
  default_route_table_tags   = { DefaultRouteTable = true }

  enable_dns_hostnames = true
  enable_dns_support   = true

  enable_nat_gateway = var.enable_nat_gateway

  #default security group - ingress/ergess deny all
  default_security_group_ingress = []
  default_security_group_egress  = []

  #VPC Flow Logs
  enable_flow_log                                 = var.enable_flow_log
  create_flow_log_cloudwatch_log_group            = var.enable_flow_log
  create_flow_log_cloudwatch_iam_role             = var.enable_flow_log
  flow_log_cloudwatch_log_group_retention_in_days = var.flow_log_cloudwatch_group_retention_in_days
  flow_log_max_aggregation_interval               = 60 #maximum time collect log of packets

  create_database_subnet_route_table = true
  database_subnet_group_name         = "${local.name_prefix}-database-subnetgroup"

  tags = local.tags
}

module "s3_gateway_endpoint" {
  source = "../../modules/terraform-aws-vpc/modules/vpc-endpoints"
  vpc_id = module.vpc.vpc_id
  endpoints = {
    s3 = {
      service           = "s3"
      "service_type"    = "Gateway"
      "route_table_ids" = module.vpc.private_route_table_ids
      tags = {
        Name = "${local.name_prefix}-s3-prefix"
      }
    }
  }
  tags = local.tags
}
