#create log group
resource "aws_cloudwatch_log_group" "ecs_service_doc" {
  name              = "${local.name_prefix}-doc-ecs-service"
  retention_in_days = var.logs_retention_day
  tags              = local.tags
}
//Task excution role
resource "aws_iam_role" "task_excution_role_doc" {
  name = "${local.name_prefix}-doc-ecs-service"
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
                    "Resource": "${aws_ecr_repository.ecr_doc.arn}",
                    "Effect": "Allow"
                },
                {
                    "Action": [
                        "logs:CreateLogStream",
                        "logs:PutLogEvents"
                    ],
                    "Resource": "${aws_cloudwatch_log_group.ecs_service_doc.arn}:*",
                    "Effect": "Allow"
                },
                {
                    "Action": "ecr:GetAuthorizationToken",
                    "Resource": "*",
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
}

resource "aws_ecs_task_definition" "doc" {
  family                   = "${local.name_prefix}-doc"
  cpu                      = var.ecs_service_doc.cpu
  memory                   = var.ecs_service_doc.memory
  execution_role_arn       = aws_iam_role.task_excution_role_doc.arn
  task_role_arn            = aws_iam_role.task_excution_role_doc.arn
  network_mode             = "bridge"
  requires_compatibilities = ["EC2"]
  tags                     = local.tags
  container_definitions = templatefile(
    "./template/task_definition/doc_container_definition.json",
    {
      IMAGE          = aws_ecr_repository.ecr_doc.repository_url
      CPU            = var.ecs_service_doc.cpu
      MEMORY         = var.ecs_service_doc.memory
      AWS_REGION     = var.region
      LOG_GROUP_NAME = aws_cloudwatch_log_group.ecs_service_doc.name
      CONTAINER_PORT = var.ecs_service_doc.container_port
      ENVIRONMENT = jsonencode([
        { "name" : "CONTAINER_ROLE", "value" : "doc" },
      ])
      SECRETS = jsonencode([
        
      ])
      HEALTH_CHECK_PATH         = var.ecs_service_doc.ecs_doc_health_check_path
      HEALTH_CHECK_INTERVAL     = var.ecs_service_doc.ecs_doc_health_check_interval
      HEALTH_CHECK_TIMEOUT      = var.ecs_service_doc.ecs_doc_health_check_timeout
      HEALTH_CHECK_RETRIES      = var.ecs_service_doc.ecs_doc_health_check_retries
      HEALTH_CHECK_START_PERIOD = var.ecs_service_doc.ecs_doc_health_check_start_period
    }
  )

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture = "X86_64"
  }
}

resource "aws_ecs_service" "doc" {
  name                              = "${local.name_prefix}-doc"
  cluster                           = aws_ecs_cluster.ecs_cluster.id
  task_definition                   = aws_ecs_task_definition.doc.arn
  desired_count                     = var.ecs_service_doc.desired_count
  enable_ecs_managed_tags           = true
  health_check_grace_period_seconds = var.ecs_service_doc.health_check_grace_period_seconds
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
    target_group_arn = aws_lb_target_group.ecs_doc.arn
    container_name   = "doc"
    container_port   = var.ecs_service_doc.container_port
  }

  ordered_placement_strategy {
    type  = var.ecs_service_doc.ordered_placement_strategy_types
    field = var.ecs_service_doc.ordered_placement_strategy_field
  }
  #ignore change with func, if u point task_definition --> Don't want terrform update
  #   lifecycle {
  #     ignore_changes = [ task_definition ]
  #   }
    # depends_on = [ aws_lb_listener.https_forward_to_tg ]
    depends_on = [ aws_lb_listener.http_forward_to_tg ]
}

resource "aws_appautoscaling_target" "ecs_doc" {
  max_capacity       = var.ecs_service_doc_autoscaling.max_capacity
  min_capacity       = var.ecs_service_doc_autoscaling.min_capacity
  resource_id        = "service/${aws_ecs_cluster.ecs_cluster.name}/${aws_ecs_service.doc.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "ecs_doc" {
  for_each = var.ecs_service_doc_autoscaling.scale_policy

  name               = "doc-step-${each.key}"
  policy_type        = "StepScaling"
  resource_id        = aws_appautoscaling_target.ecs_doc.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_doc.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_doc.service_namespace
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
resource "aws_cloudwatch_metric_alarm" "ecs_doc" {
  for_each = var.ecs_service_doc_autoscaling.scale_policy

  alarm_name          = "${local.name_prefix}-doc-${each.key}-${each.value.alarm.metric_name}"
  comparison_operator = each.value.alarm.comparison_operator
  evaluation_periods  = each.value.alarm.evaluation_periods
  threshold           = each.value.alarm.threshold

  namespace   = each.value.alarm.namespace
  period      = each.value.alarm.period
  statistic   = each.value.alarm.statistic
  metric_name = each.value.alarm.metric_name
  unit        = each.value.alarm.unit

  alarm_actions = [aws_appautoscaling_policy.ecs_doc[each.key].arn]
  dimensions = {
    ClusterName = aws_ecs_cluster.ecs_cluster.name
    ServiceName = aws_ecs_service.doc.name
  }
  tags = local.tags
}

## alarm
resource "aws_cloudwatch_metric_alarm" "ecs_service_doc" {
  for_each = var.ecs_doc_service_doc_alarm

  alarm_name          = "${local.name_prefix}-doc-${each.key}"
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
    ServiceName = aws_ecs_service.doc.name
  }
  tags = local.tags
}





