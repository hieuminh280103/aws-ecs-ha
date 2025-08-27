output "loggroup" {
  value = aws_cloudwatch_log_group.codebuild
}
output "codebuild_project" {
    value = aws_codebuild_project.codebuild
}
output "codebuild_project_name" {
    value = aws_codebuild_project.codebuild.name
}
output "codebuild_role" {
  value = data.aws_iam_role.codebuild
}