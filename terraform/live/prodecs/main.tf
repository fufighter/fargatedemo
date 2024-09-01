data "aws_region" "current" {}

provider "aws" {
  region = var.region
  assume_role {
    role_arn = "arn:aws:iam::016194978976:role/terraform-execute"
  }
}

module "prod" {
  source   = "../../modules/ecs"

  region         = var.region
  env_name       = var.env_name
  image          = var.image
  project        = var.project
  vpc_id         = local.vpc.vpc_id
  iam_ecs_arn    = local.ecs.arn
  environment_variables = local.environment_variables
  public_subnets = local.public_subnets
} 