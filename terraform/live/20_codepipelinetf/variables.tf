variable "region" {
  type        = string
  description = "Region to deploy resources"
}

variable "project" {
  type        = string
  description = "Name of the project"
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
  kms              = data.terraform_remote_state.dependencies.outputs.kms
  iam_ecs          = data.terraform_remote_state.dependencies.outputs.ecs_prod
  iam_codepipeline = data.terraform_remote_state.dependencies.outputs.codepipeline
  s3               = data.terraform_remote_state.dependencies.outputs.s3_codebuild
}