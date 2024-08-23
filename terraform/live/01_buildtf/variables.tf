variable "region" {
  type        = string
  description = "Region to deploy resources"
}

variable "env_name" {
  type        = string
  description = "Name of the environment to deploy"
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

data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket = "afu-terraform-state-backend"
    region = var.region
    key    = "afu/networking/terraform.tfstate"
  }
}

locals {
  ecr           = data.terraform_remote_state.dependencies.outputs.ecr
  iam_codebuild = data.terraform_remote_state.dependencies.outputs.codebuild
  s3            = data.terraform_remote_state.dependencies.outputs.s3_codebuild
  vpc           = data.terraform_remote_state.network.outputs["vpc"]
  private_subnets = [
    local.vpc.private_subnet_ids["afu-private1"],
    local.vpc.private_subnet_ids["afu-private2"],
    local.vpc.private_subnet_ids["afu-private3"]
  ]
  public_subnets = [
    local.vpc.public_subnet_ids["afu-public1"],
    local.vpc.public_subnet_ids["afu-public2"],
    local.vpc.public_subnet_ids["afu-public3"]
  ]
}
