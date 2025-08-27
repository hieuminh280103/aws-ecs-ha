acm_certificate_arn        = "arn:aws:acm:ap-northeast-1:*****:certificate/65832ada-8bbd-42f1-b569-491caa85a4ba"
acm_certificate_arn_global = "arn:aws:acm:us-east-1:*****:certificate/13c3ddf1-6504-4a2c-b9ab-475d7a8707af"
ConnectionArn              = "arn:aws:codestar-connections:ap-northeast-1:******:connection/8acafec3-f8c2-4d88-a117-5ad75214b8e5"
auth_token                 = "Tz9Xq2Lm8Kp4Rn5Sj7Wc3" //password redis
dynamic_asg_variable = {
  asg_max_capacity     = 3
  asg_min_capacity     = 0
  asg_desired_capacity = 1
  ec2_instance_type    = "t3a.small"
}
