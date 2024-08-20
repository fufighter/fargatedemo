data "aws_region" "current" {}

resource "aws_codepipeline" "codepipeline" {
  name     = "${var.project}tf-pipeline"
  role_arn = local.iam_codepipeline.arn

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
      name             = "Build"
      namespace        = "BuildVariables"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["SourceArtifact"]
      output_artifacts = ["BuildArtifact"]
      version          = "1"

      configuration = {
        ProjectName = "${var.project}-project"
      }
    }
  }

  stage {
    name = "TFDevPlan"

    action {
      name             = "Build"
      namespace        = "TFDev"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["BuildArtifact"]
      output_artifacts = ["TFDevPlanArtifact"]
      version          = "1"

      configuration = {
        ProjectName = "${var.project}_tfplan-project"
        EnvironmentVariables = jsonencode([{
            name  = "PIPELINE_ENV"
            type  = "PLAINTEXT"
            value = "dev"
          }
        ])
      }
    }

    action {
      category           = "Approval"
      name               = "approval"
      owner              = "AWS"
      provider           = "Manual"
      region             = data.aws_region.current.name
      run_order          = 1
      version            = "1"
    }

  }

  stage {
    name = "TFDevApply"

    action {
      name             = "Build"
      namespace        = "TFApply"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["TFDevPlanArtifact"]
      version          = "1"

      configuration = {
        ProjectName = "${var.project}_tfapply-project"
        EnvironmentVariables = jsonencode([{
            name  = "PIPELINE_ENV"
            type  = "PLAINTEXT"
            value = "dev"
          }
        ])
      }
    }

    action {
      category           = "Approval"
      name               = "approval"
      owner              = "AWS"
      provider           = "Manual"
      region             = data.aws_region.current.name
      run_order          = 1
      version            = "1"
    }

  }
}

resource "aws_codestarconnections_connection" "github" {
  name          = "github-connection"
  provider_type = "GitHub"
}