
# # CodeBuild
# module "codebuild_admin_frontend" {
#   source = "../../modules/terraform-aws-codebuild"

#   codebuild_fe                          = true
#   project                               = var.project
#   environment                           = var.environment
#   service_name                          = var.admin_frontend_service_name
#   tags                                  = local.tags
#   log_retention_in_days                 = var.codebuild_frontend.log_retention_in_days
#   vpc_id                                = module.vpc.vpc_id
#   private_subnet_ids                    = module.vpc.private_subnets
#   codebuild_build_timeout               = var.codebuild_frontend.build_timeout
#   codebuild_queued_timeout              = var.codebuild_frontend.queued_timeout
#   codebuild_compute_type                = var.codebuild_frontend.compute_type
#   codebuild_image                       = var.codebuild_frontend.image
#   codebuild_type                        = var.codebuild_frontend.type
#   codebuild_image_pull_credentials_type = var.codebuild_frontend.image_pull_credentials_type
#   codebuild_privileged_mode             = var.codebuild_frontend.privileged_mode
#   codepipeline_artifact_bucket          = [aws_s3_bucket.cicd.bucket]
#   cloudfront_distribution               = aws_cloudfront_distribution.admin_frontend_s3_distributions.arn
#   s3_frontend_bucket                    = aws_s3_bucket.admin_frontend.arn
#   codebuild_environment_variable = {
#     AWS_ACCOUNT_ID             = "${data.aws_caller_identity.current.account_id}"
#     SECRETS_MANAGER            = aws_secretsmanager_secret.admin_frontend.arn
#     CLOUDFRONT_DISTRIBUTION_ID = aws_cloudfront_distribution.admin_frontend_s3_distributions.id
#     FRONTEND_S3                = aws_s3_bucket.admin_frontend.id
#   }
#   use_secrets_manager = false
#   secrets_manager     = [aws_secretsmanager_secret.admin_frontend.arn]
#   codebuild_buildspec = file("./codebuild/admin_frontend_buildspec.yaml")
# }

# # CodePipeline
# module "codepipeline_admin_frontend" {
#   source = "../../modules/terraform-aws-cicd/codepipeline_fe"

#   project                    = var.project
#   environment                = var.environment
#   service_name               = "admin-frontend"
#   tags                       = local.tags
#   artifact_bucket            = aws_s3_bucket.cicd.bucket
#   ConnectionArn              = var.ConnectionArn
#   FullRepositoryId           = var.admin_frontend.FullRepositoryId
#   source_repo_default_branch = var.admin_frontend.default_branch
#   deploy_code_bucket_arn     = aws_s3_bucket.admin_frontend.arn
#   deploy_code_bucket         = aws_s3_bucket.admin_frontend.bucket
#   codebuild_name             = module.codebuild_admin_frontend.codebuild_project_name
#   manual_approve_comment     = var.manual_approve_comment
#   user_parameters            = "{\"distributionId\":\"${aws_cloudfront_distribution.admin_frontend_s3_distributions.id}\",\"objectPaths\":[\"\\/*\"]}"
# }
