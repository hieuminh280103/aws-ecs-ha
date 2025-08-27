# codepipeline
## codepipeline role
resource "aws_iam_role" "codepipeline" {
    name = "${local.name_prefix}-codepipeline-${var.service_name}"
    assume_role_policy = <<-POLICY
    {
        "Version": "2012-10-17",
        "Statement": [
            {
            "Effect": "Allow",
            "Principal": {
                "Service": "codepipeline.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
            }
        ]
    }
    POLICY
    tags = local.tags
}

resource "aws_iam_role_policy" "codepipeline_base" {
  name = "base"
  role = aws_iam_role.codepipeline.id
  policy = data.aws_iam_policy_document.codepipeline.json
}

resource "aws_codepipeline" "codepipeline" {
    name = "${local.name_prefix}-${var.service_name}"
    role_arn = aws_iam_role.codepipeline.arn
    tags = local.tags
    artifact_store {
        location = var.artifact_bucket
        type = "S3"
    }
    # stage {
    #   name = "Source"
    #   action {
    #     category = "Source"
    #     owner = "AWS"
    #     name = "SourceCodeCommit"
    #     provider = "CodeCommit"
    #     version = "1"
    #     configuration = {
    #       RepositoryName = "${var.source_repository_name}"
    #       BranchName     = "${var.source_repo_default_branch}"
    #       PollForSourceChanges = false
    #     }
    #     output_artifacts = ["CodeCommitArtifact"]
    #     run_order = 1
    #   }
    # }
    stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection" # 参考：https://docs.aws.amazon.com/ja_jp/codepipeline/latest/userguide/action-reference-CodestarConnectionSource.html
      version          = 1
      output_artifacts = ["Source"]

      configuration = {
        ConnectionArn        = "${var.ConnectionArn}"
        FullRepositoryId     = "${var.FullRepositoryId}"
        BranchName           = "${var.source_repo_default_branch}"
        OutputArtifactFormat = "CODE_ZIP"
      }
    }
  }
    stage {
        name = "Build"
        dynamic "action" {
          for_each = var.codebuild_action
          content {
            name = lookup(action.value, "codebuild_action_name", "BuildBeSource")
            category = "Build"
            owner = "AWS"
            provider = "CodeBuild"
            input_artifacts = ["Source"]
            output_artifacts = [action.value.output_codebuild_artifacts]
            version = 1
            configuration = {
              "ProjectName" = action.value.codebuild_project_name
            }
          }
        }
    }
     stage {
         name = "Approval"
         action {
             name = "Approval"
             owner = "AWS"
             category = "Approval"
             provider = "Manual"
             version = 1
         }
     }
    stage {
      name = "Deploy"
      dynamic "action" {
        for_each = var.ecs_services
        content {
          name = lookup(action.value, "action_name", "DeployBe")
          owner = "AWS"
          category = "Deploy"
          provider = "ECS"
          version = 1
          configuration = {
            "ClusterName" = action.value.ecs_cluster_name
            "ServiceName" = action.value.ecs_service_name
            "FileName" = lookup(action.value, "imagedefinitions", var.imagedefinitions_name)
          }
          input_artifacts = [action.value.input_codebuild_artifacts]
        }
      }
    }
    depends_on = [aws_iam_role_policy.codepipeline_base]
}

 resource "aws_iam_role" "event_rule_codepipeline" {
   name = "${local.name_prefix}-rule-codepipeline-${var.service_name}"
   assume_role_policy = <<-POLICY
     {
         "Version": "2012-10-17",
         "Statement": [
             {
             "Effect": "Allow",
             "Principal": {
                 "Service": "events.amazonaws.com"
             },
             "Action": "sts:AssumeRole"
             }
         ]
     }
     POLICY
   inline_policy {
       name = "triggerCodepipeline"
       policy = jsonencode({
         "Version": "2012-10-17",
         "Statement": [
             {
                 "Effect": "Allow",
                 "Action": [ "codepipeline:StartPipelineExecution" ],
                 "Resource": [ aws_codepipeline.codepipeline.arn ]
             }
         ]
     })
   }
 }