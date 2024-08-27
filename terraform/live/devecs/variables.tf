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
  ecs = data.terraform_remote_state.dependencies.outputs.ecs_dev
  environment_variables = [
    {"name": "VARNAME01", "value": "VARVAL01"},
    {"name": "VARNAME02", "value": "VARVAL02"}
  ]
  vpc             = data.terraform_remote_state.network.outputs["vpc"]
  private_subnets = values(local.vpc.private_subnet_ids)
  public_subnets  = values(local.vpc.public_subnet_ids)
}