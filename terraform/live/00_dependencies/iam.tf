module "iam_codebuild" {
  source = "../../modules/iam_codebuild"

  region                 = "us-east-1"
  env_name               = "dev"
  project                = "dog"
  codepipeline_accountid = data.aws_caller_identity.current.account_id
  s3_arn                 = aws_s3_bucket.s3_codebuild.arn

}

module "iam_ecs_dev" {
  source = "../../modules/iam_ecs"
  providers = {
    aws = aws.dev
  }

  region                 = "us-east-1"
  env_name               = "dev"
  project                = "dog"
  codepipeline_accountid = data.aws_caller_identity.current.account_id
  key_arn                = module.kms.key_arn
  s3_arn                 = aws_s3_bucket.s3_codebuild.arn

}

module "iam_ecs_qa" {
  source   = "../../modules/iam_ecs"
  providers = {
    aws = aws.qa
  }

  region                 = "us-east-1"
  env_name               = "qa"
  project                = "dog"
  codepipeline_accountid = data.aws_caller_identity.current.account_id
  key_arn                = module.kms.key_arn
  s3_arn                 = aws_s3_bucket.s3_codebuild.arn
}

module "iam_ecs_prod" {
  source   = "../../modules/iam_ecs"
  providers = {
    aws = aws.prod
  }

  region                 = "us-east-1"
  env_name               = "prod"
  project                = "dog"
  codepipeline_accountid = data.aws_caller_identity.current.account_id
  key_arn                = module.kms.key_arn
  s3_arn                 = aws_s3_bucket.s3_codebuild.arn
}