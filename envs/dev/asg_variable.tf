variable "dynamic_asg_variable" {
  default = {
    asg_max_capacity     = ""
    asg_min_capacity     = ""
    asg_desired_capacity = ""
    ec2_instance_type    = ""
  }
}

variable "variable_asg" {
  default = {
    device_name = "/dev/xvda"
    ami         = "ami-09363ef7dc62e5829" //ECS-optimized Amazon Linux 2023
    ebs = {
      delete_on_termination = true
      encrypt               = true
      volume_size           = 30
      volume_type           = "gp3"
    }

    alarms = {
      CPUUtilization = {
        comparison_operator = "GreaterThanThreshold"
        evaluation_periods  = 1
        datapoints_to_alarm = 1
        threshold           = 80
        period              = 300
        metric_name         = "CPUUtilization"
        namespace           = "AWS/EC2"
        statistic           = "Average"
        actions_enabled     = "true"
      }
      MemoryUsage = {
        comparison_operator = "GreaterThanThreshold"
        evaluation_periods  = 1
        datapoints_to_alarm = 1
        threshold           = 80
        period              = 300
        metric_name         = "mem_used_percent"
        namespace           = "CwAgent"
        statistic           = "Average"
        actions_enabled     = "true"
      }
      DiskUsage = {
        comparison_operator = "GreaterThanThreshold"
        evaluation_periods  = 1
        datapoints_to_alarm = 1
        threshold           = 90
        period              = 300
        metric_name         = "disk_used_percent"
        namespace           = "CwAgent"
        statistic           = "Average"
        actions_enabled     = "true"
      }
    }
  }
}
