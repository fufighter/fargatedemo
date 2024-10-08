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
      value = "#{variables.IMAGE_REPO_NAME}"
    }

    environment_variable {
      name  = "COMMIT_ID"
      value = "#{variables.COMMIT_ID}"
    }

    environment_variable {
      name  = "BRANCH_NAME"
      value = "#{variables.BRANCH_NAME}"
    }
  }

  logs_config {
    cloudwatch_logs {
      group_name  = "/aws/codebuild/${var.project}"
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
