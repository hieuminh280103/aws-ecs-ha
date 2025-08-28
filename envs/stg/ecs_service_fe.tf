#create log group
resource "aws_cloudwatch_log_group" "ecs_service_fe" {
  name              = "${local.name_prefix}-fe-ecs-service"
  retention_in_days = var.logs_retention_day
  tags              = local.tags
}
//Task excution role
resource "aws_iam_role" "task_excution_role_fe" {
  name = "${local.name_prefix}-fe-ecs-service"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
  //ecr-cloudwatch policy
  inline_policy {
    name   = "${local.name_prefix}-ecr-cloudwatch-log-policy"
    policy = <<-POLICY
        {
            "Version": "2012-10-17",
            "Statement": [
                {
                    "Action": [
                        "ecr:BatchCheckLayerAvailability",
                        "ecr:GetDownloadUrlForLayer",
                        "ecr:BatchGetImage"
                    ],
                    "Resource": "${aws_ecr_repository.ecr_frontend.arn}",
                    "Effect": "Allow"
                },
                {
                    "Action": "ecr:GetAuthorizationToken",
                    "Resource": "*",
                    "Effect": "Allow"
                },
                {
                    "Action": [
                        "logs:CreateLogStream",
                        "logs:PutLogEvents"
                    ],
                    "Resource": "${aws_cloudwatch_log_group.ecs_service_fe.arn}:*",
                    "Effect": "Allow"
                },
                {
                    "Action": [
                        "ssmmessages:CreateControlChannel",
                        "ssmmessages:CreateDataChannel",
                        "ssmmessages:OpenControlChannel",
                        "ssmmessages:OpenDataChannel"
                    ],
                    "Resource": "*",
                    "Effect": "Allow"
                }
            ]
        }
      POLICY
  }
  #secret manager
  inline_policy {
    name   = "${local.name_prefix}-secret-manager-policy"
    policy = <<-POLICY
        {
            "Version": "2012-10-17",
            "Statement": [
                {
                    "Action": [
                        "secretsmanager:GetResourcePolicy",
                        "secretsmanager:GetSecretValue",
                        "secretsmanager:DescribeSecret",
                        "secretsmanager:ListSecretVersionIds"
                    ],
                    "Resource": [
                        "${aws_secretsmanager_secret.frontend.arn}"
                    ],
                    "Effect": "Allow",
                    "Sid": "GetSecretManager"
                },
                {
                    "Action": "secretsmanager:ListSecrets",
                    "Resource": "*",
                    "Effect": "Allow",
                    "Sid": "ListSecretManagers"
                }
            ]
        }
      POLICY
  }
}

resource "aws_ecs_task_definition" "fe" {
  family                   = "${local.name_prefix}-fe"
  cpu                      = var.ecs_service_fe.cpu
  memory                   = var.ecs_service_fe.memory
  execution_role_arn       = aws_iam_role.task_excution_role_fe.arn
  task_role_arn            = aws_iam_role.task_excution_role_fe.arn
  network_mode             = "bridge"
  requires_compatibilities = ["EC2"]
  tags                     = local.tags
  container_definitions = templatefile(
    "./template/task_definition/fe_container_definition.json",
    {
      IMAGE          = aws_ecr_repository.ecr_frontend.repository_url
      CPU            = var.ecs_service_fe.cpu
      MEMORY         = var.ecs_service_fe.memory
      AWS_REGION     = var.region
      LOG_GROUP_NAME = aws_cloudwatch_log_group.ecs_service_fe.name
      CONTAINER_PORT = var.ecs_service_fe.container_port
      ENVIRONMENT = jsonencode([
        { "name" : "CONTAINER_ROLE", "value" : "frontend" },
      ])
      SECRETS = jsonencode([
        { "name" : "NEXT_PUBLIC_API_URL", "valueFrom" : "${aws_secretsmanager_secret.frontend.arn}:NEXT_PUBLIC_API_URL::" },
        { "name" : "NEXT_PUBLIC_DOC_URL", "valueFrom" : "${aws_secretsmanager_secret.frontend.arn}:NEXT_PUBLIC_DOC_URL::" },
      ])
      HEALTH_CHECK_PATH         = var.ecs_service_fe.ecs_fe_health_check_path
      HEALTH_CHECK_INTERVAL     = var.ecs_service_fe.ecs_fe_health_check_interval
      HEALTH_CHECK_TIMEOUT      = var.ecs_service_fe.ecs_fe_health_check_timeout
      HEALTH_CHECK_RETRIES      = var.ecs_service_fe.ecs_fe_health_check_retries
      HEALTH_CHECK_START_PERIOD = var.ecs_service_fe.ecs_fe_health_check_start_period
    }
  )

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture = "X86_64"
  }
}

resource "aws_ecs_service" "fe" {
  name                              = "${local.name_prefix}-fe"
  cluster                           = aws_ecs_cluster.ecs_cluster.id
  task_definition                   = aws_ecs_task_definition.fe.arn
  desired_count                     = var.ecs_service_fe.desired_count
  enable_ecs_managed_tags           = true
  health_check_grace_period_seconds = var.ecs_service_fe.health_check_grace_period_seconds
  scheduling_strategy               = "REPLICA"
  enable_execute_command            = true
  tags                              = local.tags

  capacity_provider_strategy {
    weight            = 1
    base              = 0
    capacity_provider = aws_ecs_capacity_provider.ecs_cluster.name
  }

  deployment_controller {
    type = "ECS"
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.ecs_fe.arn
    container_name   = "frontend"
    container_port   = var.ecs_service_fe.container_port
  }

  ordered_placement_strategy {
    type  = var.ecs_service_fe.ordered_placement_strategy_types
    field = var.ecs_service_fe.ordered_placement_strategy_field
  }
  #ignore change with func, if u point task_definition --> Don't want terrform update
  #   lifecycle {
  #     ignore_changes = [ task_definition ]
  #   }
    # depends_on = [ aws_lb_listener.https_forward_to_tg ]
    depends_on = [ aws_lb_listener.http_forward_to_tg ]
}

resource "aws_appautoscaling_target" "ecs_fe" {
  max_capacity       = var.ecs_service_fe_autoscaling.max_capacity
  min_capacity       = var.ecs_service_fe_autoscaling.min_capacity
  resource_id        = "service/${aws_ecs_cluster.ecs_cluster.name}/${aws_ecs_service.fe.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "ecs_fe" {
  for_each = var.ecs_service_fe_autoscaling.scale_policy

  name               = "fe-step-${each.key}"
  policy_type        = "StepScaling"
  resource_id        = aws_appautoscaling_target.ecs_fe.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_fe.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_fe.service_namespace
  step_scaling_policy_configuration {
    cooldown                 = each.value.cooldown
    adjustment_type          = each.value.adjustment_type
    metric_aggregation_type  = "Average"
    min_adjustment_magnitude = 0
    step_adjustment {
      metric_interval_lower_bound = each.value.metric_interval_lower_bound
      metric_interval_upper_bound = each.value.metric_interval_upper_bound
      scaling_adjustment          = each.value.scaling_adjustment
    }
  }
}

######################################
#####CLoudwatch Alarm#################
######################################
resource "aws_cloudwatch_metric_alarm" "ecs_fe" {
  for_each = var.ecs_service_fe_autoscaling.scale_policy

  alarm_name          = "${local.name_prefix}-fe-${each.key}-${each.value.alarm.metric_name}"
  comparison_operator = each.value.alarm.comparison_operator
  evaluation_periods  = each.value.alarm.evaluation_periods
  threshold           = each.value.alarm.threshold

  namespace   = each.value.alarm.namespace
  period      = each.value.alarm.period
  statistic   = each.value.alarm.statistic
  metric_name = each.value.alarm.metric_name
  unit        = each.value.alarm.unit

  alarm_actions = [aws_appautoscaling_policy.ecs_fe[each.key].arn]
  dimensions = {
    ClusterName = aws_ecs_cluster.ecs_cluster.name
    ServiceName = aws_ecs_service.fe.name
  }
  tags = local.tags
}

## alarm
resource "aws_cloudwatch_metric_alarm" "ecs_service_fe" {
  for_each = var.ecs_fe_service_fe_alarm

  alarm_name          = "${local.name_prefix}-fe-${each.key}"
  comparison_operator = each.value.comparison_operator
  evaluation_periods  = each.value.evaluation_periods
  datapoints_to_alarm = each.value.datapoints_to_alarm
  threshold           = each.value.threshold
  period              = each.value.period
  metric_name         = each.value.metric_name
  namespace           = each.value.namespace
  statistic           = each.value.statistic
  actions_enabled     = each.value.actions_enabled
  alarm_actions       = []
  ok_actions          = []
  dimensions = {
    ClusterName = aws_ecs_cluster.ecs_cluster.name
    ServiceName = aws_ecs_service.fe.name
  }
  tags = local.tags
}





