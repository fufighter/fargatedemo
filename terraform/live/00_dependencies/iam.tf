module "iam_codebuild" {
  source = "../../modules/iam_codebuild"

  region                 = "us-east-1"
  env_name               = "dev"
  project                = "dog"
  codepipeline_accountid = data.aws_caller_identity.current.account_id
  s3_arn                 = aws_s3_bucket.s3_codebuild.arn

}

module "iam_ecs" {
  source = "../../modules/iam_ecs"

  region                 = "us-east-1"
  env_name               = "dev"
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