module "asg" {
  source           = "../../modules/terraform-aws-autoscaling-7.6.1"
  name             = "${local.name_prefix}-asg"
  min_size         = var.dynamic_asg_variable.asg_min_capacity
  max_size         = var.dynamic_asg_variable.asg_max_capacity
  desired_capacity = var.dynamic_asg_variable.asg_desired_capacity
  #ASG will wait to the ec2 health. If set to 0 --> Will not wait to healthy 
  # and create new ec2 if it have to do --> Risk Ec2 not healthy
  wait_for_capacity_timeout = 0
  health_check_type         = "EC2"
  vpc_zone_identifier       = [module.vpc.private_subnets[0], module.vpc.private_subnets[1]]?
  # protect_from_scale_in = true


  ########Launch Template###########3
  launch_template_name        = "${local.name_prefix}-template-ecs"
  launch_template_description = "Launch template for asg"
  key_name                    = var.key_pem?
  update_default_version      = true
  security_groups             = [aws_security_group.asg_sg.id]
  iam_instance_profile_arn    = aws_iam_instance_profile.ec2_instance_profile.arn

  image_id          = var.variable_asg.ami
  instance_type     = var.dynamic_asg_variable.ec2_instance_type
  enable_monitoring = true
  #ebs_optimized     = true

  block_device_mappings = [{
    device_name = var.variable_asg.device_name
    no_device   = 0
    ebs         = var.variable_asg.ebs
  }]

  user_data = base64encode(data.template_file.asg_user_data.rendered)
  tags      = merge({ key = "Amazon ECS managed" }, local.tags)
}

data "template_file" "asg_user_data" {
  template = file("./scripts/user-data.sh")?

  vars = {
    ecs_cluster_name             = aws_ecs_cluster.ecs_cluster.name
    name_prefix                  = local.name_prefix
  }
}

#############Security group############ 
##Only allow traffic come from bastion host##
resource "aws_security_group" "asg_sg" {
  name        = "${local.name_prefix}-asg-sg"
  description = "Allow inbound traffic"
  vpc_id      = var.vpc.vpc_id
  # depends_on  = [module.vpc]


  ingress {
    description     = "Allow from master ALB"
    from_port       = 0
    to_port         = 65535
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }
  ingress {
    description     = "Allow SSH from bastion host"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [module.nat-bastion.sg_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge({ Name = "${local.name_prefix}-asg-sg" }, local.tags)
}

#############################
#IAM role, instance profile
##########################
#Create iam role
#######################
resource "aws_iam_role" "ec2_role" {
  name = "${local.name_prefix}-application-role"
  tags = local.tags
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
    "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy",
    "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
  ]

  assume_role_policy = <<-EOT
  {
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "ec2.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
  }
  EOT
}

#Map to instance profile
resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "${local.name_prefix}-ec2-instance-profile"
  role = aws_iam_role.ec2_role.name
  tags = local.tags
}

############
#Alarm
############
resource "aws_cloudwatch_metric_alarm" "asg_high_cpu_alarm" {
  alarm_name          = "${local.name_prefix}-asg-HighCPUAlarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "3"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "70"

  dimensions = {
    AutoScalingGroupName = module.asg.autoscaling_group_name
  }

  alarm_description = "This metric monitors ec2 cpu utilization"
  # insufficient_data_actions = [aws_sns_topic.alarm_sns.arn]
  # alarm_actions = [
  #   aws_sns_topic.alarm_sns.arn
  # ]
  # ok_actions = [aws_sns_topic.alarm_sns.arn]
}

resource "aws_cloudwatch_metric_alarm" "disk_used_percent" {
  alarm_name          = "${local.name_prefix}-disk-used-percent"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "3"
  metric_name         = "disk_used_percent"
  namespace           = "AWS/EC2"
  period              = "300"
  statistic           = "Average"
  threshold           = "80"

  dimensions = {
    AutoScalingGroupName = module.asg.autoscaling_group_name
  }

  alarm_description = "This metric monitors ec2 cpu disk_used_percent"
  # Action
  # insufficient_data_actions = [aws_sns_topic.alarm_sns.arn]
  # alarm_actions = [
  #   aws_sns_topic.alarm_sns.arn
  # ]
}
