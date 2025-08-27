resource "aws_ecs_cluster" "ecs_cluster" {
  name = "${local.name_prefix}-cluster"
  setting {
    name = "containerInsights"
    value =  "${var.enabled_container_insights}"
  }
  tags = local.tags
}

resource "aws_ecs_capacity_provider" "ecs_cluster" {
  name = "api_provider"
  auto_scaling_group_provider {
    auto_scaling_group_arn = module.asg.autoscaling_group_arn
    # Can turn on when protection from scale in enable in asg
    # managed_termination_protection = "ENABLED"
    managed_scaling {
      maximum_scaling_step_size = 1000
      minimum_scaling_step_size = 1
      status = "ENABLED"
      target_capacity = 100
    }
  }
  tags = local.tags
}
resource "aws_ecs_cluster_capacity_providers" "ecs_cluster-capacity" {
  cluster_name = aws_ecs_cluster.ecs_cluster.name

  capacity_providers = [aws_ecs_capacity_provider.ecs_cluster.name]
  default_capacity_provider_strategy {
    base = 1
    capacity_provider = aws_ecs_capacity_provider.ecs_cluster.name
  }
}