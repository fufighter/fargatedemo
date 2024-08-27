data "aws_region" "current" {}

provider "aws" {
  region = var.region
  assume_role {
    role_arn = "arn:aws:iam::898649339363:role/terraform-execute"
  }
}

module "dev" {
  source   = "../../modules/ecs"

  region         = var.region
  env_name       = var.env_name
  image          = var.image
  project        = var.project
  vpc_id         = local.vpc.vpc_id
  iam_ecs_arn    = local.ecs.arn
  app_port       = 8080
  environment_variables = local.environment_variables
  public_subnets = local.public_subnets
} 