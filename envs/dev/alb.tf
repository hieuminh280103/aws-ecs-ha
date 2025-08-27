resource "aws_lb" "ecs_alb" {
  name               = "${local.name_prefix}-ecs-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = module.vpc.public_subnets

  access_logs {
    bucket  = aws_s3_bucket.service_logs.id
    prefix  = "alb"
    enabled = true
  }
  tags = local.tags
}

####targer group - follow ecs service

resource "aws_lb_target_group" "ecs_api" {
  name     = "${local.name_prefix}-ecs-api-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc.vpc_id

  health_check {
    enabled             = true
    interval            = 60
    path                = "/"
    port                = "traffic-port"
    healthy_threshold   = 3
    unhealthy_threshold = 5
    timeout             = 6
  }
}

resource "aws_lb_target_group" "ecs_fe" {
  name     = "${local.name_prefix}-ecs-fe-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = module.vpc.vpc_id

  health_check {
    enabled             = true
    interval            = 60
    path                = "/"
    port                = "traffic-port"
    healthy_threshold   = 3
    unhealthy_threshold = 5
    timeout             = 6
  }
}


#######alb-listener#########
#######################

resource "aws_lb_listener" "https_forward_to_tg" {
  load_balancer_arn = aws_lb.ecs_alb.arn
  port              = 443
  protocol          = "HTTPS"
  certificate_arn   = var.acm_certificate_arn?
  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "Sorry, this is not the correct domain for our application"
      status_code  = "200"
    }
  }
}
#Forward to fe tg
resource "aws_lb_listener_rule" "api" {
  listener_arn = aws_lb_listener.https_forward_to_tg.arn
  priority     = 2
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ecs_api.arn
  }
  condition {
    path_pattern {
      values = ["/api/*"]
    }
  }
}

#Forward to fe tg
resource "aws_lb_listener_rule" "fe" {
  listener_arn = aws_lb_listener.https_forward_to_tg.arn
  priority     = 3
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ecs_fe.arn
  }
  condition {
    path_pattern {
      values = ["/*"]
    }
  }
}

# #######SG -alb############
resource "aws_security_group" "alb_sg" {
  name        = "${local.name_prefix}-alb-sg"
  description = "Allow inbound traffic"
  vpc_id      = var.vpc.vpc_id
  ingress = [
    {
      description      = "HTTP"
      from_port        = 80
      to_port          = 80
      protocol         = "tcp"
      cidr_blocks      = var.cidr_blocks
      ipv6_cidr_blocks = var.ipv6_cidr_blocks
      prefix_list_ids  = []
      security_groups  = []
      self             = false
    },
    {
      description      = "HTTPS"
      from_port        = 443
      to_port          = 443
      protocol         = "tcp"
      cidr_blocks      = var.cidr_blocks
      ipv6_cidr_blocks = var.ipv6_cidr_blocks
      prefix_list_ids  = []
      security_groups  = []
      self             = false
    }
  ]
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = var.cidr_blocks
    ipv6_cidr_blocks = var.ipv6_cidr_blocks
  }
  tags = merge({ Name = "${local.name_prefix}-alb-sg" }, local.tags)
}

resource "aws_cloudwatch_metric_alarm" "admin_target_group_status_frontend" {
  alarm_name          = "${local.name_prefix}-api-tg-Status-Check"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "UnHealthyHostCount"
  namespace           = "AWS/ApplicationELB"
  period              = "300"
  statistic           = "Average"
  threshold           = "1"
  actions_enabled     = "true"

  dimensions = {
    TargetGroup  = aws_lb_target_group.ecs_api.arn
    LoadBalancer = aws_lb.ecs_alb.arn
  }

  alarm_description = "This metric monitors Healtcheck"
}

