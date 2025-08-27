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

resource "aws_iam_role_policy" "codepipeline_frontend_policy" {
  name = "${local.name_prefix}-codepipeline-${var.service_name}-policy"
  role = aws_iam_role.codepipeline.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect":"Allow",
      "Action": [
        "s3:GetObject",
        "s3:GetObjectVersion",
        "s3:GetBucketVersioning",
        "s3:PutObjectAcl",
        "s3:PutObject"
      ],
      "Resource": [
        "${var.deploy_code_bucket_arn}",
        "${var.deploy_code_bucket_arn}/*"
      ]
    }
  ]
}
EOF
}


resource "aws_codepipeline" "codepipeline" {
  name = "${local.name_prefix}-${var.service_name}"
  role_arn = aws_iam_role.codepipeline.arn
  tags = local.tags
  artifact_store {
    location = var.artifact_bucket
    type = "S3"
  }
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
     name = "Approval"
     action {
       name = "Approval"
       owner = "AWS"
       category = "Approval"
       provider = "Manual"
       version = 1
       configuration = {
         CustomData = var.manual_approve_comment
       }
     }
   }
  stage {
    name = "Build"
    action {
      name = "BuildFeSource"
      category = "Build"
      owner = "AWS"
      provider = "CodeBuild"
      input_artifacts = ["Source"]
      output_artifacts = ["CodeBuildArtifact"]
      version = 1
      configuration = {
        "ProjectName" = var.codebuild_name
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