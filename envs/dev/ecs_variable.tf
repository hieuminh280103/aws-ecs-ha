variable "enabled_container_insights" {
  default = "disabled"
}
#######################################3
#######ecs-admin-api-service###############
#######################################
variable "ecs_service_admin_api" {
  default = {
    cpu                                             = 512
    memory                                          = 450
    desired_count                                   = 0
    container_port                                  = 80
    health_check_grace_period_seconds               = 60
    ordered_placement_strategy_types                = "spread"
    ordered_placement_strategy_field                = "attribute:ecs.availability-zone"
    ecs_admin_api_health_check_path         = "/"
    ecs_admin_api_health_check_interval     = 30
    ecs_admin_api_health_check_timeout      = 5
    ecs_admin_api_health_check_retries      = 3
    ecs_admin_api_health_check_start_period = 60
  }
}

variable "ecs_service_admin_api_autoscaling" {
  default = {
    min_capacity = 0
  
    max_capacity = 2
    scale_policy = {
      "scale-out" = {
        cooldown        = 120
        adjustment_type = "ChangeInCapacity"
        #Base on different between the alarm thresold and the Cloudwatch metric value
        #Goi la khoang giua, = Cloudwatch metric interval - threshold
        #--> lower 0 --> If cloudwatch metric > 80 --> Cloudwatch metric - threshold > 0 
        # --> Metric interval bound  > 0 --> scale out 
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

variable "ecs_api_service_admin_api_alarm" {
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

###############################################
#######ecs-admin-worker-service####################
#######################################

variable "ecs_service_admin_worker" {
  default = {
    cpu                               = 512
    memory                            = 450
    desired_count                     = 0
    container_port                    = 80
    health_check_grace_period_seconds = 60
    ordered_placement_strategy_types  = "spread"
    ordered_placement_strategy_field  = "attribute:ecs.availability-zone"
  }
}

variable "ecs_service_admin_worker_autoscaling" {
  default = {
    min_capacity = 0
    max_capacity = 0
    scale_policy = {
      "scale-out" = {
        cooldown        = 120
        adjustment_type = "ChangeInCapacity"
        #Base on different between the alarm thresold and the Cloudwatch metric value
        #Goi la khoang giua, = Cloudwatch metric interval - threshold
        #--> lower 0 --> If cloudwatch metric > 80 --> Cloudwatch metric - threshold > 0 
        # --> Metric interval bound  > 0 --> scale out 
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

variable "ecs_service_admin_worker_alarm" {
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


##########################################
############# ecs-admin-batch ##################
##########################################

variable "ecs_service_admin_batch" {
  default = {
    cpu                               = 256
    memory                            = 512
    desired_count                     = 0
    container_port                    = 80
    host_port                         = 80
    health_check_grace_period_seconds = 60
    ordered_placement_strategy_types  = "spread"
    ordered_placement_strategy_field  = "attribute:ecs.availability-zone"
  }
}

variable "ecs_service_admin_batch_autoscaling" {
  default = {
    min_capacity = 0
    max_capacity = 2
    scale_policy = {
      "scale-out" = {
        cooldown        = 120
        adjustment_type = "ChangeInCapacity"
        #Base on different between the alarm thresold and the Cloudwatch metric value
        #Goi la khoang giua, = Cloudwatch metric interval - threshold
        #--> lower 0 --> If cloudwatch metric > 80 --> Cloudwatch metric - threshold > 0 
        # --> Metric interval bound  > 0 --> scale out 
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

variable "ecs_service_admin_batch_alarm" {
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