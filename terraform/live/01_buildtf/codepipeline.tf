resource "aws_codepipeline" "codepipeline" {
  name          = "${var.project}tf-pipeline"
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
        ConnectionArn        = aws_codestarconnections_connection.github.arn
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
          },
          {
            name  = "COMMIT_ID"
            type  = "PLAINTEXT"
            value = "#{SourceVariables.CommitId}"
          },
          {
            name  = "BRANCH_NAME"
            type  = "PLAINTEXT"
            value = "#{SourceVariables.BranchName}"
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

  stage {
    name = "TFDev"

    action {
      name             = "Dev_Terraform_Plan"
      namespace        = "TFDevPlan"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["TFDevSecArtifact"]
      output_artifacts = ["TFDevPlanArtifact"]
      version          = "1"

      configuration = {
        ProjectName = module.codebuild["tfplan"].codebuild.id
        EnvironmentVariables = jsonencode(
          [{
            name  = "ENVIRONMENT"
            type  = "PLAINTEXT"
            value = "dev"
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
      input_artifacts  = ["TFDevApplyArtifact"]
      output_artifacts = ["TFProdPlanArtifact"]
      version          = "1"

      configuration = {
        ProjectName = module.codebuild["tfplan"].codebuild.id
        EnvironmentVariables = jsonencode(
          [{
            name  = "ENVIRONMENT"
            type  = "PLAINTEXT"
            value = "prod"
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

resource "aws_codestarconnections_connection" "github" {
  name          = "github-connection"
  provider_type = "GitHub"
}