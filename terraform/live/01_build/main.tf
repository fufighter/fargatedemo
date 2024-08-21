data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

provider "aws" {
  region = var.region
}

module "dev" {
  source   = "../../modules/codebuild"

  region                 = var.region
  env_name               = var.env_name
  project                = var.project
  repo_name              = var.project
  buildspec              = "buildspec.yml"
  branch                 = "main"
  source_location        = "https://github.com/fufighter/fargatedemo"
  source_type            = "GITHUB"
  s3_name                = local.s3.bucket
  iam_codebuild_arn      = local.iam_codebuild.arn
  codepipeline_accountid = data.aws_caller_identity.current.account_id
} 