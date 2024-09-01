resource "aws_codepipeline" "build_release" {
  name          = "${var.project}tf-build-release"
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

  trigger {
    provider_type = "CodeStarSourceConnection"
    git_configuration {
      source_action_name = "Source"
      push {
        branches {
          includes = ["release*"]
        }
      }
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
        ConnectionArn        = aws_codestarconnections_connection.github_release.arn
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

resource "aws_codepipeline" "deploy_release" {
  name          = "${var.project}tf-deploy-release"
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

  trigger {
    provider_type = "CodeStarSourceConnection"
    git_configuration {
      source_action_name = "GitHub"
      push {
        branches {
          includes = ["release*"]
        }
        file_paths {
          includes = ["terraform/live/prodecs/*"]
        }
      }
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
        RepositoryName = local.ecr_release.name
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
        ConnectionArn        = aws_codestarconnections_connection.github_release.arn
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

  stage {
    name = "TFQa"

    action {
      name             = "Qa_Terraform_Plan"
      namespace        = "TFQaPlan"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["ECRArtifact", "SourceArtifact"]
      output_artifacts = ["TFQaPlanArtifact"]
      version          = "1"

      configuration = {
        PrimarySource        = "SourceArtifact"
        ProjectName          = module.codebuild["tfplan_ecr"].codebuild.id
        EnvironmentVariables = jsonencode(
          [{
            name  = "ENVIRONMENT"
            type  = "PLAINTEXT"
            value = "qa"
          },
          {
            name = "IMAGE_URI"
            type = "PLAINTEXT"
            value = "#{ECRVariables.ImageURI}"
          }]
        )
      }
    }

    action {
      name             = "Terraform_Plan_Approval"
      category         = "Approval"
      owner            = "AWS"
      provider         = "Manual"
      region           = var.region
      run_order        = 2
      version          = "1"
    }

    action {
      name             = "Qa_Terraform_Apply"
      namespace        = "TFQaApply"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["TFQaPlanArtifact"]
      output_artifacts = ["TFQaApplyArtifact"]
      run_order        = 3
      version          = "1"

      configuration = {
        ProjectName = module.codebuild["tfapply"].codebuild.id
        EnvironmentVariables = jsonencode(
          [{
            name  = "ENVIRONMENT"
            type  = "PLAINTEXT"
            value = "qa"
          },
          {
            name  = "ECS_STATUS_ROLE"
            type  = "PLAINTEXT"
            value = local.ecs_qa
          },
          {
            name  = "IMAGE_REPO_NAME"
            type  = "PLAINTEXT"
            value = var.project
          }]
        )
      }
    }

    action {
      name             = "Terraform_Apply_Approval"
      category         = "Approval"
      owner            = "AWS"
      provider         = "Manual"
      region           = var.region
      run_order        = 4
      version          = "1"
    }
  }

  stage {
    name = "TFProd"

    action {
      name             = "Prod_Terraform_Plan"
      namespace        = "TFProdPlan"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["ECRArtifact", "SourceArtifact"]
      output_artifacts = ["TFProdPlanArtifact"]
      version          = "1"

      configuration = {
        PrimarySource        = "SourceArtifact"
        ProjectName          = module.codebuild["tfplan_ecr"].codebuild.id
        EnvironmentVariables = jsonencode(
          [{
            name  = "ENVIRONMENT"
            type  = "PLAINTEXT"
            value = "prod"
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
      name             = "Terraform_Plan_Approval"
      category         = "Approval"
      owner            = "AWS"
      provider         = "Manual"
      region           = var.region
      run_order        = 2
      version          = "1"
    }

    action {
      name             = "Prod_Terraform_Apply"
      namespace        = "TFProdApply"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["TFProdPlanArtifact"]
      output_artifacts = ["TFProdApplyArtifact"]
      run_order        = 3
      version          = "1"

      configuration = {
        ProjectName = module.codebuild["tfapply"].codebuild.id
        EnvironmentVariables = jsonencode(
          [{
            name  = "ENVIRONMENT"
            type  = "PLAINTEXT"
            value = "prod"
          },
          {
            name  = "ECS_STATUS_ROLE"
            type  = "PLAINTEXT"
            value = local.ecs_prod
          },
          {
            name  = "IMAGE_REPO_NAME"
            type  = "PLAINTEXT"
            value = var.project
          }]
        )
      }
    }

    action {
      name             = "Terraform_Apply_Approval"
      category         = "Approval"
      owner            = "AWS"
      provider         = "Manual"
      region           = var.region
      run_order        = 4
      version          = "1"
    }
  }
}

resource "aws_codestarconnections_connection" "github_release" {
  name          = "github-connection-release"
  provider_type = "GitHub"
}