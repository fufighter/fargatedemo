resource "aws_codebuild_project" "project" {
  name          = "${var.project}-tf"
  description   = "${var.project} builder"
  build_timeout = 5
  service_role  = var.iam_codebuild_arn

  artifacts {
    type                   = "S3"
    location               = var.s3_name
    override_artifact_name = true
  }

  cache {
    type     = "S3"
    location = var.s3_name
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/amazonlinux2-x86_64-standard:5.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"

    environment_variable {
      name  = "AWS_DEFAULT_REGION"
      value = var.region
    }

    environment_variable {
      name  = "AWS_ACCOUNT_ID"
      value = var.codepipeline_accountid
    }

    environment_variable {
      name  = "IMAGE_REPO_NAME"
      value = "${var.project}"
    }

    environment_variable {
      name  = "ENVIRONMENT"
      value = "${var.env_name}"
    }
  }

  logs_config {
    cloudwatch_logs {
      group_name  = "/aws/codebuild/${var.project}/tf${var.env_name}"
    }
  }

  source {
    buildspec       = var.buildspec
    type            = "S3"
    location        = var.location
  }
}
