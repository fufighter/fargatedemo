data "aws_region" "current" {}

provider "aws" {
  region = var.region
}

module "dev" {
  source   = "../../modules/ecs"

  region         = var.region
  env_name       = var.env_name
  image          = var.image
  project        = var.project
  vpc_id         = local.vpc.vpc_id
  iam_ecs_arn    = local.iam_ecs.arn
  app_port       = 8080
  public_subnets = local.public_subnets
} 