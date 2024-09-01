variable "region" {
  type        = string
  description = "Region to deploy resources"
}

variable "project" {
  type        = string
  description = "Name of the project"
}

variable "buildprojects" {
  type        = map
  description = "List of CodeBuild Projects"
}

data "terraform_remote_state" "dependencies" {
  backend = "s3"
  config = {
    bucket = "afu-terraform-state-backend"
    region = var.region
    key    = "afu/dependencies/terraform.tfstate"
  }
}

locals {
  ecr_dev          = data.terraform_remote_state.dependencies.outputs.ecr_dev
  ecr_release      = data.terraform_remote_state.dependencies.outputs.ecr_release
  ecs_dev          = data.terraform_remote_state.dependencies.outputs.ecs_dev.arn
  ecs_qa           = data.terraform_remote_state.dependencies.outputs.ecs_qa.arn
  ecs_prod         = data.terraform_remote_state.dependencies.outputs.ecs_prod.arn
  iam_codebuild    = data.terraform_remote_state.dependencies.outputs.codebuild
  iam_codepipeline = data.terraform_remote_state.dependencies.outputs.codepipeline
  kms              = data.terraform_remote_state.dependencies.outputs.kms
  s3               = data.terraform_remote_state.dependencies.outputs.s3_codebuild
}