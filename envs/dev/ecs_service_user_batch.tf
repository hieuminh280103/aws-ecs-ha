
resource "aws_cloudwatch_log_group" "ecs_service_user_batch" {
  name              = "${local.name_prefix}-user-batch"
  retention_in_days = var.logs_retention_day
  tags              = local.tags
}

resource "aws_iam_role" "task_excution_role_batch" {
  name = "${local.name_prefix}-user-batch-ecs-service"
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
  #Using admin-api to run image
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
                    "Resource": "${aws_ecr_repository.ecr_admin_backend.arn}",
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
                    "Resource": "${aws_cloudwatch_log_group.ecs_service_user_batch.arn}:*",
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
                        "${aws_secretsmanager_secret.admin_api.arn}"
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

resource "aws_ecs_task_definition" "admin_batch" {
  family = "${local.name_prefix}-admin-batch-service"
  requires_compatibilities = ["FARGATE"]
  cpu = var.ecs_service_admin_batch.cpu
  memory = var.ecs_service_admin_batch.memory
  network_mode = "awsvpc"
  task_role_arn = aws_iam_role.task_excution_role_batch.arn
  execution_role_arn = aws_iam_role.task_excution_role_batch.arn
  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }

  tags = local.tags
  container_definitions = jsonencode([
    {
      name = "batch-cron-task" #container name
      # image = "${aws_ecr_repository.ecr_api_api_admin.repository_url}"
      image = "nginxdemos/hello"
      cpu = var.ecs_service_admin_batch.cpu
      memory = var.ecs_service_admin_batch.memory
      essential = true
      portMappings = [{
        containerPort = var.ecs_service_admin_batch.container_port
        hostPort = var.ecs_service_admin_batch.host_port
      }]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group = aws_cloudwatch_log_group.ecs_service_user_batch.name
          awslogs-region = var.region
          awslogs-stream-prefix = "ecs-task"
        }
      }
      environment = []
      secrets = []
    }
  ])
}

