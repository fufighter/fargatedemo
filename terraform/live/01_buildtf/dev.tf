resource "aws_codepipeline" "build_dev" {
  name          = "${var.project}tf-build-dev"
  pipeline_type = "V2"
  role_arn      = local.iam_codepipeline.arn

  artifact_store {
    location = local.s3.bucket
    type     = "S3"

    encryption_key {
      id   = local.kms
      type = "KMS"
    }

  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      namespace        = "SourceVariables"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["SourceArtifact"]

      configuration = {
        BranchName           = "main"
        ConnectionArn        = aws_codestarconnections_connection.github_dev.arn
        FullRepositoryId     = "fufighter/fargatedemo"
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "DockerFile"
      namespace        = "BuildVariables"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["SourceArtifact"]
      output_artifacts = ["BuildArtifact"]
      version          = "1"

      configuration = {
        ProjectName = module.codebuild["docker"].codebuild.id
        EnvironmentVariables = jsonencode([
          {
            name  = "COMMIT_ID"
            type  = "PLAINTEXT"
            value = "#{SourceVariables.CommitId}"
          },
          {
            name  = "BRANCH_NAME"
            type  = "PLAINTEXT"
            value = "#{SourceVariables.BranchName}"
          },
          {
            name  = "IMAGE_REPO_NAME"
            type  = "PLAINTEXT"
            value = "${var.project}_release"
          }]
        )
      }
    }
  }

  stage {
    name = "TFDevSec"

    action {
      name             = "TFDevSec"
      namespace        = "TFDevSec"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["BuildArtifact"]
      output_artifacts = ["TFDevSecArtifact"]
      version          = "1"

      configuration = {
        ProjectName = module.codebuild["tfsec"].codebuild.id
      }
    }

    action {
      name             = "approval"
      category         = "Approval"
      owner            = "AWS"
      provider         = "Manual"
      region           = var.region
      run_order        = 2
      version          = "1"
    }

  }
}

resource "aws_codepipeline" "deploy_dev" {
  name          = "${var.project}tf-deploy-dev"
  pipeline_type = "V2"
  role_arn      = local.iam_codepipeline.arn

  artifact_store {
    location = local.s3.bucket
    type     = "S3"

    encryption_key {
      id   = local.kms
      type = "KMS"
    }

  }

  stage {
    name = "Source"

    action {
      name             = "ECR"
      namespace        = "ECRVariables"
      category         = "Source"
      owner            = "AWS"
      provider         = "ECR"
      version          = "1"
      output_artifacts = ["ECRArtifact"]

      configuration = {
        RepositoryName = local.ecr_dev.name
      }
    }

    action {
      name             = "GitHub"
      namespace        = "SourceVariables"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["SourceArtifact"]

      configuration = {
        BranchName           = "main"
        ConnectionArn        = aws_codestarconnections_connection.github_dev.arn
        FullRepositoryId     = "fufighter/fargatedemo"
      }
    }
  }

  stage {
    name = "TFDevSec"

    action {
      name             = "TFDevSec"
      namespace        = "TFDevSec"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["SourceArtifact"]
      output_artifacts = ["TFDevSecArtifact"]
      version          = "1"

      configuration = {
        ProjectName = module.codebuild["tfsec"].codebuild.id
      }
    }

  }

  stage {
    name = "TFDev"

    action {
      name             = "Dev_Terraform_Plan"
      namespace        = "TFDevPlan"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["ECRArtifact", "SourceArtifact"]
      output_artifacts = ["TFDevPlanArtifact"]
      version          = "1"

      configuration = {
        PrimarySource        = "SourceArtifact"
        ProjectName          = module.codebuild["tfplan_ecr"].codebuild.id
        EnvironmentVariables = jsonencode(
          [{
            name  = "ENVIRONMENT"
            type  = "PLAINTEXT"
            value = "dev"
          },
          {
            name = "IMAGE_URI"
            type = "PLAINTEXT"
            value = "#{ECRVariables.ImageURI}"
          }
          ]
        )
      }
    }

    action {
      name             = "Dev_Terraform_Apply"
      namespace        = "TFDevApply"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["TFDevPlanArtifact"]
      output_artifacts = ["TFDevApplyArtifact"]
      run_order        = 3
      version          = "1"

      configuration = {
        ProjectName = module.codebuild["tfapply"].codebuild.id
        EnvironmentVariables = jsonencode(
          [{
            name  = "ENVIRONMENT"
            type  = "PLAINTEXT"
            value = "dev"
          },
          {
            name  = "ECS_STATUS_ROLE"
            type  = "PLAINTEXT"
            value = local.ecs_dev
          }]
        )
      }
    }
  }
}

resource "aws_codestarconnections_connection" "github_dev" {
  name          = "github-connection-dev"
  provider_type = "GitHub"
}