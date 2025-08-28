resource "aws_cloudwatch_dashboard" "monitoring" {
  dashboard_name = "${local.name_prefix}-monitoring-dashboard"
  dashboard_body = <<EOF
  {
    "widgets": [
      ${data.template_file.widget_tg_api_request_count.rendered},
      ${data.template_file.widget_tg_api_healthy_host_count.rendered},
      ${data.template_file.widget_tg_api_respone_time.rendered},
      ${data.template_file.widget_tg_api_http_error.rendered},
      ${data.template_file.widget_asg_cpu.rendered},
      ${data.template_file.widget_asg_cpu_credit_balance.rendered}
    ]
  }
  EOF
}
###########Server####################

data "template_file" "widget_tg_api_healthy_host_count" {
  template = file("./template/right_half_width_metrics_widget.tpl")
  vars = {
    period   = "60"
    stat     = "Average"
    region   = var.region
    title    = "TG Healthy Host"
    liveData = "true"
    metrics = jsonencode([
      ["AWS/ApplicationELB", "HealthyHostCount", "TargetGroup", aws_lb_target_group.ecs_api.arn_suffix, "LoadBalancer", aws_lb.ecs_alb.arn_suffix],
    ])
  }
}
data "template_file" "widget_tg_api_http_error" {
  template = file("./template/left_half_width_metrics_widget.tpl")
  vars = {
    period   = "60"
    stat     = "Sum"
    region   = var.region
    title    = "TG HTTP ERROR"
    liveData = "true"
    metrics = jsonencode([
      ["AWS/ApplicationELB", "HTTPCode_Target_5XX_Count", "TargetGroup", aws_lb_target_group.ecs_api.arn_suffix, "LoadBalancer", aws_lb.ecs_alb.arn_suffix],
    ])
  }
}

data "template_file" "widget_tg_api_request_count" {
  template = file("./template/right_half_width_metrics_widget.tpl")
  vars = {
    period   = "60"
    stat     = "Sum"
    region   = var.region
    title    = "TG Request Count"
    liveData = "true"
    metrics = jsonencode([
      ["AWS/ApplicationELB", "RequestCountPerTarget", "TargetGroup", aws_lb_target_group.ecs_api.arn_suffix, "LoadBalancer", aws_lb.ecs_alb.arn_suffix],
    ])
  }
}

data "template_file" "widget_tg_api_respone_time" {
  template = file("./template/left_half_width_metrics_widget.tpl")
  vars = {
    period   = "60"
    stat     = "Average"
    region   = var.region
    title    = "TG Respond Time"
    liveData = "true"
    metrics = jsonencode([
      ["AWS/ApplicationELB", "TargetResponseTime", "TargetGroup", aws_lb_target_group.ecs_api.arn_suffix, "LoadBalancer", aws_lb.ecs_alb.arn_suffix],
    ])
  }
}



##############################################3
########ASG - Metric
#######################################
data "template_file" "widget_asg_cpu" {
  template = file("./template/right_half_width_metrics_widget.tpl")
  vars = {
    period   = "60"
    stat     = "Average"
    region   = var.region
    title    = "Server CPUUtilization"
    liveData = "true"
    metrics = jsonencode([
      ["AWS/EC2", "CPUUtilization", "AutoScalingGroupName", module.asg.autoscaling_group_name],
    ])
  }
}
data "template_file" "widget_asg_cpu_credit_balance" {
  template = file("./template/left_half_width_metrics_widget.tpl")
  vars = {
    period   = "60"
    stat     = "Average"
    region   = var.region
    title    = "Server CPUCreditBalance"
    liveData = "true"
    metrics = jsonencode([
      ["AWS/EC2", "CPUCreditBalance", "AutoScalingGroupName", module.asg.autoscaling_group_name],
    ])
  }
}




