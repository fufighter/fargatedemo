resource "aws_codebuild_project" "project" {
  name          = "${var.project}-project"
  description   = "${var.project} builder"
  build_timeout = var.timeout
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
      value = "${var.repo_name}"
    }

    environment_variable {
      name  = "ENVIRONMENT"
      value = "${var.env_name}"
    }
  }

  logs_config {
    cloudwatch_logs {
      group_name  = "/aws/codebuild/${var.project}/${var.env_name}"
    }
  }

  source {
    buildspec       = var.buildspec
    type            = var.source_type
    location        = var.source_location
    git_clone_depth = 1
    
    git_submodules_config {
      fetch_submodules = true
    }
  }

  source_version = var.branch
}
