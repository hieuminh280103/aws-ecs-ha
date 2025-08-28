#####CLoudwatch Log#######
resource "aws_cloudwatch_log_group" "slow_log" {
  name              = "/elasticache/${local.name_prefix}/slow-log"
  retention_in_days = var.logs_retention_day
  tags              = local.tags
}
resource "aws_cloudwatch_log_group" "engine_log" {
  name              = "/elasticache/${local.name_prefix}/engine-log"
  retention_in_days = var.logs_retention_day
  tags              = local.tags
}

######################################
#######Parameter Group ###############
######################################
resource "aws_elasticache_parameter_group" "redis_parameter" {
  name        = "${local.name_prefix}-custom-redis7-cluster-on"
  family      = var.redis_cluster_config.family
  description = "redis parameter for redis 7"
  parameter {
    name  = "cluster-enabled"
    value = "yes"
  }
  tags = local.tags
}
#################################
###Redis##############
###############
resource "aws_elasticache_replication_group" "redis_cluster" {
  engine                     = var.redis_cluster_config.engine
  engine_version             = var.redis_cluster_config.engine_version
  automatic_failover_enabled = true
  subnet_group_name          = aws_elasticache_subnet_group.elasticache_subnet.name
  replication_group_id       = "${local.name_prefix}-${var.redis_cluster_config.replication_group_id}"
  description                = var.redis_cluster_config.description
  node_type                  = var.redis_cluster_config.node_type
  parameter_group_name       = aws_elasticache_parameter_group.redis_parameter.name
  port                       = var.redis_cluster_config.port
  multi_az_enabled           = var.redis_cluster_config.multi_az_enabled
  num_node_groups            = var.redis_cluster_config.num_node_groups
  replicas_per_node_group    = var.redis_cluster_config.replicas_per_node_group
  at_rest_encryption_enabled = var.redis_cluster_config.at_rest_encryption_enabled
  kms_key_id                 = var.kms_key_id
  transit_encryption_enabled = var.redis_cluster_config.transit_encryption_enabled
  auth_token                 = var.auth_token
  security_group_ids         = [aws_security_group.elasticcache.id]
  log_delivery_configuration {
    destination      = aws_cloudwatch_log_group.slow_log.name
    destination_type = "cloudwatch-logs"
    log_format       = "json"
    log_type         = "slow-log"
  }
  log_delivery_configuration {
    destination      = aws_cloudwatch_log_group.engine_log.name
    destination_type = "cloudwatch-logs"
    log_format       = "json"
    log_type         = "engine-log"
  }
  apply_immediately = var.redis_cluster_config.apply_immediately
  tags = local.tags
}

#Store the Elastic Cache endpoint and port number as parameters in SSM
# resource "aws_ssm_parameter" "elasticcache_endpoint" {
#   name = "/elasticache/"
# }

resource "aws_elasticache_subnet_group" "elasticache_subnet" {
  name       = "${local.name_prefix}-cache-subnet"
  subnet_ids = module.vpc.database_subnets
}

resource "aws_security_group" "elasticcache" {
  name        = "${local.name_prefix}-elastic-cache"
  vpc_id      = module.vpc.vpc_id
  description = "Allow inbound and outbound access from user-api"
  ingress {
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    security_groups = [aws_security_group.asg_sg.id] // allow from backend-service
  }
  ingress {
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    security_groups = [module.nat-bastion.sg_id] // allow from bastion nat
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = local.tags
}


