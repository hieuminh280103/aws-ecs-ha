# #codebuild
# module "codebuild_admin_backend" {
#   source                                = "../../modules/terraform-aws-codebuild"
#   codebuild_fe                          = false #Create invalidation iam (clear cache)
#   project                               = var.project
#   environment                           = var.environment
#   service_name                          = var.admin_backend_service_name
#   tags                                  = local.tags
#   log_retention_in_days                 = var.codebuild_backend.log_retention_in_days
#   vpc_id                                = module.vpc.vpc_id
#   private_subnet_ids                    = module.vpc.private_subnets
#   codebuild_build_timeout               = var.codebuild_backend.build_timeout
#   codebuild_queued_timeout              = var.codebuild_backend.queued_timeout
#   codebuild_compute_type                = var.codebuild_backend.compute_type
#   codebuild_image                       = var.codebuild_backend.image
#   codebuild_type                        = var.codebuild_backend.type #To distinguish ARM vs x86 architecture
#   codebuild_image_pull_credentials_type = var.codebuild_backend.image_pull_credentials_type
#   codebuild_privileged_mode             = var.codebuild_backend.privileged_mode
#   codepipeline_artifact_bucket          = [aws_s3_bucket.cicd.bucket]
#   codebuild_environment_variable = {
#     REPOSITORY_NAME = "${aws_ecr_repository.ecr_admin_backend.name}"
#     AWS_ACCOUNT_ID  = "${data.aws_caller_identity.current.account_id}"
#     IMAGE_TAG       = "latest"
#   }
#   codebuild_buildspec = file("./codebuild/admin_backend_buildspec.yaml")
#   codebuild_policy = {
#     "ecr" : jsonencode({
#       "Version" : "2012-10-17",
#       "Statement" : [
#         {
#           "Action" : [
#             "ecr:BatchCheckLayerAvailability",
#             "ecr:GetDownloadUrlForLayer",
#             "ecr:BatchGetImage",
#             "ecr:InitiateLayerUpload",
#             "ecr:UploadLayerPart",
#             "ecr:CompleteLayerUpload",
#             "ecr:PutImage"
#           ],
#           "Resource" : ["${aws_ecr_repository.ecr_admin_backend.arn}"],
#           "Effect" : "Allow"
#         },
#         {
#           "Action" : "ecr:GetAuthorizationToken",
#           "Resource" : "*",
#           "Effect" : "Allow"
#         }
#       ]
#     })
#   }
# }

# module "codepipeline_admin_backend" {
#   source       = "../../modules/terraform-aws-cicd/codepipeline_be"
#   service_name = var.admin_backend_service_name
#   project      = var.project
#   environment  = var.environment
#   tags         = local.tags
#   artifact_bucket = aws_s3_bucket.cicd.bucket
#   ConnectionArn = var.ConnectionArn
#   FullRepositoryId = var.admin_backend.FullRepositoryId
#   source_repo_default_branch = var.admin_backend.default_branch
#   codebuild_action = [
#     {
#       codebuild_action_name = "BuildAdminBackend"
#       codebuild_project_name = module.codebuild_admin_backend.codebuild_project_name
#       output_codebuild_artifacts = "AdminBackendArtifact"
#     }
#   ]
#   ecs_services = [
#     {
#       action_name = "DeployAdminAPI"
#       ecs_cluster_name = aws_ecs_cluster.ecs_cluster.name
#       ecs_service_name = aws_ecs_service.admin_api.name
#       input_codebuild_artifacts = "AdminBackendArtifact"
#     },
#     {
#        action_name = "DeployAdminWorker"
#        ecs_cluster_name = aws_ecs_cluster.ecs_cluster.name
#        ecs_service_name = aws_ecs_service.admin_worker.name
#        input_codebuild_artifacts = "AdminBackendArtifact"
#     }
#   ]
  
# }

