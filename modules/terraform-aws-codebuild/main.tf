# codebuild be seucirty group 
resource "aws_security_group" "codebuild" {
    count = var.in_vpc ? 1 : 0

    name = "${local.name_prefix}-codebuild-${var.service_name}"
    description = "${var.project} ${var.environment} codebuild for service ${var.service_name}"
    vpc_id = var.vpc_id
    tags = local.tags
    ingress = []
    egress = [{
        description = "ALLOW ALL"
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
        ipv6_cidr_blocks = ["::/0"]
        prefix_list_ids = []
        security_groups = []
        self = false
    }]
}
# codebuild loggroup
resource "aws_cloudwatch_log_group" "codebuild" {
    name = "${local.name_prefix}-codebuild-${var.service_name}"
    retention_in_days = var.log_retention_in_days
    tags = local.tags
}
# codebuild iam role
resource "aws_iam_role" "codebuild" {
    count = var.create_codebuild_role ? 1 : 0

    name = "${local.name_prefix}-codebuild-${var.service_name}"
    assume_role_policy = <<-POLICY
    {
        "Version": "2012-10-17",
        "Statement": [
            {
            "Effect": "Allow",
            "Principal": {
                "Service": "codebuild.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
            }
        ]
    }
    POLICY
    tags = local.tags
}
## role policy 
resource "aws_iam_role_policy" "codebuild_default" {
  count = var.create_codebuild_role && var.in_vpc ? 1 : 0
  name = "default"
  role = aws_iam_role.codebuild[0].id
  policy = data.aws_iam_policy_document.codebuild_vpc_policy[0].json
}
resource "aws_iam_role_policy" "codebuild_codepipeline_artifact" {
  for_each = toset(var.codepipeline_artifact_bucket)
  
  name = "codepipeline-artifact-${each.key}"
  role = aws_iam_role.codebuild[0].id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:GetObject",
          "s3:PutObject"
        ]
        Effect = "Allow"
        Resource = [
          "arn:aws:s3:::${each.value}/*"
        ]
      }
    ]
  })
}
resource "aws_iam_role_policy" "codebuild_codepipeline_secrets_manager" {
  count = var.use_secrets_manager ? 1 : 0
  name = "codepipeline-secrets-manager"
  role = aws_iam_role.codebuild[0].id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret",
          "secretsmanager:GetResourcePolicy",
          "secretsmanager:ListSecretVersionIds"
        ]
        Effect = "Allow"
        Resource = ["*"]
      }
    ]
  })
}
resource "aws_iam_role_policy" "codebuild_logs" {
  count = var.create_codebuild_role ? 1 : 0
  name = "logs"
  role = aws_iam_role.codebuild[0].id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Effect = "Allow"
        Resource = [
          aws_cloudwatch_log_group.codebuild.arn,
          "${aws_cloudwatch_log_group.codebuild.arn}:*"
        ]
      },
    ]
  })
}

resource "aws_iam_role_policy" "codebuild_create_invalidation" {
  count = var.codebuild_fe ? 1 : 0
  name = "create-cloudfront-invalidation"
  role = aws_iam_role.codebuild[0].id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "cloudfront:CreateInvalidation",
          "cloudfront:GetInvalidation"
        ]
        Effect = "Allow"
        Resource = [ 
          var.cloudfront_distribution
        ]
      },
    ]
  })
}

resource "aws_iam_role_policy" "codebuild_s3_access" {
  count = var.codebuild_fe ? 1 : 0
  name = "access-s3-bucket"
  role = aws_iam_role.codebuild[0].id
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect":"Allow",
      "Action": [
        "s3:GetObject",
        "s3:GetObjectAcl",
        "s3:PutObjectAcl",
        "s3:PutObject",
        "s3:ListObject"
      ],
      "Resource": [
        "${var.s3_frontend_bucket}/*"
      ]
    },
    {
      "Effect":"Allow",
      "Action": [
        "s3:ListBucket"
      ],
      "Resource": [
        "${var.s3_frontend_bucket}"
      ]
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "codebuild_dynamic_policy" {
    for_each = var.codebuild_policy 

    name = each.key
    role = aws_iam_role.codebuild[0].id
    policy = each.value
}

resource "aws_codebuild_project" "codebuild" {
    name = "${local.name_prefix}-${var.service_name}"
    description = "codebuild image for service ${var.service_name}"
    build_timeout = var.codebuild_build_timeout
    queued_timeout = var.codebuild_queued_timeout
    service_role = data.aws_iam_role.codebuild.arn
    tags = local.tags
    
    artifacts {
        type = "CODEPIPELINE"
    }

    environment {
        compute_type = var.codebuild_compute_type
        image = var.codebuild_image
        type = var.codebuild_type
        image_pull_credentials_type = var.codebuild_image_pull_credentials_type
        privileged_mode = var.codebuild_privileged_mode
        dynamic "environment_variable" {
            for_each = var.codebuild_environment_variable
            content {
                name  = environment_variable.key
                value = environment_variable.value
            }
        }
    }

    source {
        type = "CODEPIPELINE"
        buildspec = var.codebuild_buildspec
    }

    logs_config {
        cloudwatch_logs {
            group_name = aws_cloudwatch_log_group.codebuild.name
            status = "ENABLED"
        }
    }

    dynamic "vpc_config" {
        for_each = local.vpc_configs
        content {
            vpc_id = vpc_config.value.vpc_id
            subnets = vpc_config.value.subnets
            security_group_ids = vpc_config.value.security_group_ids
        }
    }
}
