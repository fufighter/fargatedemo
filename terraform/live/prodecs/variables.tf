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

variable "image" {
  type        = string
  description = "Name of the image"
}

data "terraform_remote_state" "dependencies" {
  backend = "s3"
  config = {
    bucket = "afu-terraform-state-backend"
    region = "us-east-1"
    key    = "afu/dependencies/terraform.tfstate"
  }
}

data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = "afu-terraform-state-backend"
    region = "us-east-1"
    key    = "vpc/terraform.tfstate"
  }
}

locals {
  app_port        = 8080
  ecs             = data.terraform_remote_state.dependencies.outputs.ecs_prod
  vpc             = data.terraform_remote_state.vpc.outputs["vpc"]
  private_subnets = values(local.vpc.private_subnet_ids)
  public_subnets  = values(local.vpc.public_subnet_ids)
}
