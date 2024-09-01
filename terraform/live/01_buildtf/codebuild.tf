module "codebuild" {
  for_each = var.buildprojects
  source   = "../../modules/codebuild"

  region                 = var.region
  project                = "${var.project}_${each.key}"
  buildspec              = each.value
  branch                 = "main"
  source_location        = "https://github.com/fufighter/fargatedemo"
  source_type            = "GITHUB"
  s3_name                = local.s3.bucket
  iam_codebuild_arn      = local.iam_codebuild.arn
  codepipeline_accountid = data.aws_caller_identity.current.account_id
}
