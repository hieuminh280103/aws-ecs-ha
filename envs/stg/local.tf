locals {
  tags = {
    Project   = var.project
    Env       = var.environment
    Create_by = var.create_by
  }
}

locals {
  name_prefix = "${var.project}-${var.environment}"
}
# locals {
#   target_group_s0_arn = module.alb.target_group_arns[0]
# }


locals {
  combined_private_subnets_cidr_blocks = concat(
    module.vpc.private_subnets_cidr_blocks,
    module.vpc.database_subnets_cidr_blocks
  )

  combined_private_route_table_ids = concat(
    module.vpc.private_route_table_ids,
    module.vpc.database_route_table_ids
  )
}

