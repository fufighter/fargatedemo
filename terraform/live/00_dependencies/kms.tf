module "kms" {
  source = "terraform-aws-modules/kms/aws"

  description = "Codepipeline"
  key_usage   = "ENCRYPT_DECRYPT"

  # Policy
  key_administrators = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
  key_users          = [
    module.iam_codebuild.codebuild.arn,
    module.iam_codebuild.codepipeline.arn
  ]

  # Aliases
  aliases = ["codepipeline"]

}