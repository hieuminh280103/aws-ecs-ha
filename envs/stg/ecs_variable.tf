variable "enabled_container_insights" {
  default = "disabled"
}
#######################################3
#######ecs-api-service###############
#######################################
variable "ecs_service_api" {
  default = {
  cpu                                             = 1024
  memory                                          = 512
    desired_count                                   = 0
    container_port                                  = 8000
    health_check_grace_period_seconds               = 60
    ordered_placement_strategy_types                = "spread"
    ordered_placement_strategy_field                = "attribute:ecs.availability-zone"
    ecs_api_health_check_path         = "/health"
    ecs_api_health_check_interval     = 30
    ecs_api_health_check_timeout      = 5
    ecs_api_health_check_retries      = 3
    ecs_api_health_check_start_period = 60
  }
}

variable "ecs_service_api_autoscaling" {
  default = {
    min_capacity = 0
  
    max_capacity = 2
    scale_policy = {
      "scale-out" = {
        cooldown        = 120
        adjustment_type = "ChangeInCapacity"
        metric_interval_lower_bound = 0
        metric_interval_upper_bound = ""
        scaling_adjustment          = 1
        alarm = {
          namespace           = "AWS/ECS"
          period              = "60"
          statistic           = "Average"
          metric_name         = "CPUUtilization"
          unit                = "Percent"
          comparison_operator = "GreaterThanOrEqualToThreshold"
          evaluation_periods  = 3
          threshold           = 80
        }
      }

      "scale-in" = {
        cooldown                    = 120
        adjustment_type             = "ChangeInCapacity"
        metric_interval_lower_bound = ""
        metric_interval_upper_bound = 0
        scaling_adjustment          = -1
        alarm = {
          namespace           = "AWS/ECS"
          period              = "60"
          statistic           = "Average"
          metric_name         = "CPUUtilization"
          unit                = "Percent"
          comparison_operator = "LessThanOrEqualToThreshold"
          evaluation_periods  = 10
          threshold           = 35
        }
      }
    }
  }
}

variable "ecs_api_service_api_alarm" {
  default = {
    CPUUtilization = {
      comparison_operator = "GreaterThanThreshold"
      evaluation_periods  = 3
      datapoints_to_alarm = 1
      threshold           = 80
      period              = 60
      metric_name         = "CPUUtilization"
      namespace           = "AWS/ECS"
      statistic           = "Average"
      actions_enabled     = "true"
    }
    MemoryUtilization = {
      comparison_operator = "GreaterThanThreshold"
      evaluation_periods  = 3
      datapoints_to_alarm = 1
      threshold           = 80
      period              = 60
      metric_name         = "MemoryUtilization"
      namespace           = "AWS/ECS"
      statistic           = "Average"
      actions_enabled     = "true"
    }
  }
}

#######################################3
#######ecs-fe-service###############
#######################################
variable "ecs_service_fe" {
  default = {
  cpu                                             = 2048
  memory                                          = 1024
    desired_count                                   = 0
    container_port                                  = 3000
    health_check_grace_period_seconds               = 60
    ordered_placement_strategy_types                = "spread"
    ordered_placement_strategy_field                = "attribute:ecs.availability-zone"
    ecs_fe_health_check_path         = "/"
    ecs_fe_health_check_interval     = 30
    ecs_fe_health_check_timeout      = 5
    ecs_fe_health_check_retries      = 3
    ecs_fe_health_check_start_period = 60
  }
}

variable "ecs_service_fe_autoscaling" {
  default = {
    min_capacity = 0
  
    max_capacity = 2
    scale_policy = {
      "scale-out" = {
        cooldown        = 120
        adjustment_type = "ChangeInCapacity"
        metric_interval_lower_bound = 0
        metric_interval_upper_bound = ""
        scaling_adjustment          = 1
        alarm = {
          namespace           = "AWS/ECS"
          period              = "60"
          statistic           = "Average"
          metric_name         = "CPUUtilization"
          unit                = "Percent"
          comparison_operator = "GreaterThanOrEqualToThreshold"
          evaluation_periods  = 3
          threshold           = 80
        }
      }

      "scale-in" = {
        cooldown                    = 120
        adjustment_type             = "ChangeInCapacity"
        metric_interval_lower_bound = ""
        metric_interval_upper_bound = 0
        scaling_adjustment          = -1
        alarm = {
          namespace           = "AWS/ECS"
          period              = "60"
          statistic           = "Average"
          metric_name         = "CPUUtilization"
          unit                = "Percent"
          comparison_operator = "LessThanOrEqualToThreshold"
          evaluation_periods  = 10
          threshold           = 35
        }
      }
    }
  }
}

variable "ecs_fe_service_fe_alarm" {
  default = {
    CPUUtilization = {
      comparison_operator = "GreaterThanThreshold"
      evaluation_periods  = 3
      datapoints_to_alarm = 1
      threshold           = 80
      period              = 60
      metric_name         = "CPUUtilization"
      namespace           = "AWS/ECS"
      statistic           = "Average"
      actions_enabled     = "true"
    }
    MemoryUtilization = {
      comparison_operator = "GreaterThanThreshold"
      evaluation_periods  = 3
      datapoints_to_alarm = 1
      threshold           = 80
      period              = 60
      metric_name         = "MemoryUtilization"
      namespace           = "AWS/ECS"
      statistic           = "Average"
      actions_enabled     = "true"
    }
  }
}

#######################################3
#######ecs-doc-service###############
#######################################
variable "ecs_service_doc" {
  default = {
  cpu                                             = 1024
  memory                                          = 512
    desired_count                                   = 0
    container_port                                  = 3000
    health_check_grace_period_seconds               = 60
    ordered_placement_strategy_types                = "spread"
    ordered_placement_strategy_field                = "attribute:ecs.availability-zone"
    ecs_doc_health_check_path         = "/"
    ecs_doc_health_check_interval     = 30
    ecs_doc_health_check_timeout      = 5
    ecs_doc_health_check_retries      = 3
    ecs_doc_health_check_start_period = 60
  }
}

variable "ecs_service_doc_autoscaling" {
  default = {
    min_capacity = 0
  
    max_capacity = 2
    scale_policy = {
      "scale-out" = {
        cooldown        = 120
        adjustment_type = "ChangeInCapacity"
        metric_interval_lower_bound = 0
        metric_interval_upper_bound = ""
        scaling_adjustment          = 1
        alarm = {
          namespace           = "AWS/ECS"
          period              = "60"
          statistic           = "Average"
          metric_name         = "CPUUtilization"
          unit                = "Percent"
          comparison_operator = "GreaterThanOrEqualToThreshold"
          evaluation_periods  = 3
          threshold           = 80
        }
      }

      "scale-in" = {
        cooldown                    = 120
        adjustment_type             = "ChangeInCapacity"
        metric_interval_lower_bound = ""
        metric_interval_upper_bound = 0
        scaling_adjustment          = -1
        alarm = {
          namespace           = "AWS/ECS"
          period              = "60"
          statistic           = "Average"
          metric_name         = "CPUUtilization"
          unit                = "Percent"
          comparison_operator = "LessThanOrEqualToThreshold"
          evaluation_periods  = 10
          threshold           = 35
        }
      }
    }
  }
}

variable "ecs_doc_service_doc_alarm" {
  default = {
    CPUUtilization = {
      comparison_operator = "GreaterThanThreshold"
      evaluation_periods  = 3
      datapoints_to_alarm = 1
      threshold           = 80
      period              = 60
      metric_name         = "CPUUtilization"
      namespace           = "AWS/ECS"
      statistic           = "Average"
      actions_enabled     = "true"
    }
    MemoryUtilization = {
      comparison_operator = "GreaterThanThreshold"
      evaluation_periods  = 3
      datapoints_to_alarm = 1
      threshold           = 80
      period              = 60
      metric_name         = "MemoryUtilization"
      namespace           = "AWS/ECS"
      statistic           = "Average"
      actions_enabled     = "true"
    }
  }
}

