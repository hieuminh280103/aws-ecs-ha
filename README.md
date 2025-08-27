# Infra terrafom

## Requirement
### Backend S3 bucket
```
cd terraform/scripts/
# with aws-profile is project-dev, environment is dev
./init.sh project-dev dev
```
### Terraform
- version 1.0.7

Linux
https://releases.hashicorp.com/terraform/1.0.7/terraform_1.0.7_linux_amd64.zip

MacOs
- x86: https://releases.hashicorp.com/terraform/1.0.7/terraform_1.0.7_darwin_amd64.zip
- Arm: https://releases.hashicorp.com/terraform/1.0.7/terraform_1.0.7_darwin_arm64.zip

## Edit variables

## Terraform init

```
terraform init
```

## Terraform plan

```
$ terraform plan -out ./.terraform/terraform.plan -var-file variable.tfvars
```
Improve performance when running terraform plan:
```
terraform plan --parallelism x -out ./.terraform/terraform.plan -var-file variable.tfvars
# With x is parallelism process number, example x=30
```
## Terraform apply

```
terraform apply "./.terraform/terraform.plan"
```

# Application Auto Scaling
You install jq on your computer
```$xslt
sudo apt-get install jq
```
## Dynamic Scaling
List dynamic scaling for ecs:
```$xslt
aws application-autoscaling describe-scaling-policies --service-namespace ecs  --profile project-dev --region ap-northeast-1 | jq '.ScalingPolicies[].PolicyName'
```
```
"s3-api-step-scale-out"
"s4-test-grading-step-scale-out-queue-high"
"s4-api-step-scale-in"
"s4-test-analysis-step-scale-in-queue-low"
"s1-api-step-scale-out"
"s4-test-grading-step-scale-in-queue-low"
"s4-test-analysis-step-scale-out-queue-high"
"s4-api-step-scale-out"
"s1-api-step-scale-in"
"s3-api-step-scale-in"
```
Describe scale policy detail, example with s1-api-step-scale-in:
```$xslt
aws application-autoscaling describe-scaling-policies --service-namespace ecs --policy-names s1-api-step-scale-in  --profile project-dev --region ap-northeast-1 | jq
```

## Schedule Scaling
### List schedule scaling for ecs

```
aws application-autoscaling describe-scheduled-actions --service-namespace ecs --profile project-dev --region ap-northeast-1 | jq '.ScheduledActions[].ScheduledActionName'
```

```$xslt
"s4-api-schedule-scale-out"
"s1-api-schedule-scale-in"
"s3-api-schedule-scale-in"
"s1-api-schedule-scale-out"
"s3-api-schedule-scale-out"
"s4-api-schedule-scale-in"
```

### Describe schedule detail, example with s1-api-schedule-scale-in:
```
aws application-autoscaling describe-scheduled-actions --service-namespace ecs --scheduled-action-names s1-api-schedule-scale-in --profile project-dev --region ap-northeast-1 | jq
```

### Update schedule scale:
You wanna schedule scale when:
schedule: cron(15 11 * * ? *)
MinCapacity=1
MaxCapacity=4

```
aws application-autoscaling put-scheduled-action --profile project-dev --region ap-northeast-1 --service-namespace ecs --scheduled-action-name s1-api-schedule-scale-in --resource-id service/project-dev-api-cluster/project-dev-s3-api --schedule "cron(15 11 * * ? *)" --scalable-dimension ecs:service:DesiredCount --scalable-target-action MinCapacity=1,MaxCapacity=4
```

Review results:
```$xslt
aws application-autoscaling describe-scheduled-actions --service-namespace ecs --scheduled-action-names s1-api-schedule-scale-in --profile project-dev --region ap-northeast-1 | jq
```

Delete schedule scale:
Refer: https://docs.aws.amazon.com/cli/latest/reference/application-autoscaling/index.html#available-commands


### Execute with ECS Task:

List Tasks by ECS Service:
```aws ecs list-tasks --profile project-dev --region ap-northeast-1 --cluster project-dev-api-cluster --service-name project-dev-s1-cron | jq```
Command Format:
```aws ecs execute-command --profile $PROFILE --region $REGION --cluster $CLUSTER_NAME --task $TASK_ID --command "command" --interactive```

Case 1: Execute directly on ECS Task (Container)
```aws ecs execute-command --profile project-dev --region ap-northeast-1 --cluster project-dev-api-cluster --task 09f4cb9eed4344efa5a2fa559f857e6c --command "/bin/bash" --interactive```

Case 2: Run Command on ECS Task, such as: php artisan exam:change-status

```aws ecs execute-command --profile project-dev --region ap-northeast-1 --cluster project-dev-api-cluster --task 09f4cb9eed4344efa5a2fa559f857e6c --command "php artisan exam:change-status" --interactive```

