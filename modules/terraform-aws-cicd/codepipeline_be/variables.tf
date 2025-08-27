variable "service_name" { }
variable "tags" {}
variable "project" {}
variable "environment" {}
variable "artifact_bucket" {}
variable "ConnectionArn" {}
variable "FullRepositoryId" {}
variable "source_repo_default_branch" {}
#variable "codebuild_name" {}
variable "codebuild_action" {}
variable "ecs_services" {}
variable "imagedefinitions_name" {
  default = "imagedefinitions.json"
}