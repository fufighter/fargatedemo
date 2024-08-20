data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

provider "aws" {
  region = var.region
}

module "tfsec" {
  source   = "../../modules/codebuild"

  region                 = var.region
  env_name               = var.env_name
  project                = "${var.project}_tfsec"
  buildspec              = "buildspec_tfsec.yml"
  branch                 = "main"
  repo_name              = var.project  
  s3_name                = local.s3.bucket
  iam_codebuild_arn      = local.iam_codebuild.arn
  codepipeline_accountid = data.aws_caller_identity.current.account_id
}

module "tfplan" {
  source   = "../../modules/codebuild"

  region                 = var.region
  env_name               = var.env_name
  project                = "${var.project}_tfplan"
  buildspec              = "buildspec_tfplan.yml"
  branch                 = "main"
  repo_name              = var.project  
  s3_name                = local.s3.bucket
  iam_codebuild_arn      = local.iam_codebuild.arn
  codepipeline_accountid = data.aws_caller_identity.current.account_id
}

module "tfapply" {
  source   = "../../modules/codebuild"

  region                 = var.region
  env_name               = var.env_name
  project                = "${var.project}_tfapply"
  buildspec              = "buildspec_tfapply.yml"
  branch                 = "main"
  repo_name              = var.project  
  s3_name                = local.s3.bucket
  iam_codebuild_arn      = local.iam_codebuild.arn
  codepipeline_accountid = data.aws_caller_identity.current.account_id
}