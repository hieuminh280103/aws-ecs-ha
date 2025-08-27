resource "aws_scheduler_schedule" "batch_1" {
  name = "trigger-demo-ecs"
  flexible_time_window {
    mode = var.event_bridge_config.flexible_time_window
  }
  schedule_expression = "${var.event_bridge_config.batch_1_sechule_expression}"
  schedule_expression_timezone = "${var.event_bridge_config.schedule_expression_timezone}"
  target {
    arn      = aws_ecs_cluster.ecs_cluster.arn
    role_arn = aws_iam_role.event_bridge_trigger_ecs.arn
    ecs_parameters {
      task_count = var.event_bridge_config.task_count
    //Task definition of batch
      task_definition_arn = aws_ecs_task_definition.admin_batch.arn
      launch_type = "FARGATE"
      network_configuration {
        subnets = module.vpc.private_subnets
        assign_public_ip = var.event_bridge_config.assign_public_ip
        security_groups = [aws_security_group.asg_sg.id]
      }
    }
  }
}

resource "aws_iam_role" "event_bridge_trigger_ecs" {
  name = "${local.name_prefix}-event_bridge_trigger_ecs"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "scheduler.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
  inline_policy {
    name   = "${local.name_prefix}-eventbridge-invoke-ecs"
    policy = <<-POLICY
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "ecs:RunTask"
        ],
        "Resource": [
          "${aws_ecs_task_definition.admin_batch.arn}:*",
          "${aws_ecs_task_definition.admin_batch.arn}"
        ],
        "Condition": {
          "ArnLike": {
            "ecs:cluster": "${aws_ecs_cluster.ecs_cluster.arn}"
          }
        }
      },
      {
        "Effect": "Allow",
        "Action": "iam:PassRole",
        "Resource": [
          "*"
        ],
        "Condition": {
          "StringLike": {
            "iam:PassedToService": "ecs-tasks.amazonaws.com"
          }
        }
      }
    ]
  }
  POLICY
  }
}
