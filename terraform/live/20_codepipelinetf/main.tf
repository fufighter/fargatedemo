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
    name = "TFDevSec"

    action {
      name             = "Build"
      namespace        = "TFDevSec"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["BuildArtifact"]
      output_artifacts = ["TFDevSecArtifact"]
      version          = "1"

      configuration = {
        ProjectName = "${var.project}_tfsec-project"
      }
    }

    action {
      category           = "Approval"
      name               = "approval"
      owner              = "AWS"
      provider           = "Manual"
      region             = var.region
      run_order          = 2
      version            = "1"
    }

  }

  stage {
    name = "TFDevPlan"

    action {
      name             = "Build"
      namespace        = "TFDevPlan"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["TFDevSecArtifact"]
      output_artifacts = ["TFDevPlanArtifact"]
      version          = "1"

      configuration = {
        ProjectName = "${var.project}_tfplan-project"
      }
    }

    action {
      category           = "Approval"
      name               = "approval"
      owner              = "AWS"
      provider           = "Manual"
      region             = var.region
      run_order          = 2
      version            = "1"
    }

  }

  stage {
    name = "TFDevApply"

    action {
      name             = "Build"
      namespace        = "TFDevApply"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["TFDevPlanArtifact"]
      output_artifacts = ["TFDevApplyArtifact"]
      version          = "1"

      configuration = {
        ProjectName = "${var.project}_tfapply-project"
      }
    }

    action {
      category           = "Approval"
      name               = "approval"
      owner              = "AWS"
      provider           = "Manual"
      region             = var.region
      run_order          = 2
      version            = "1"
    }

  }

  stage {
    name = "TFProdPlan"

    action {
      name             = "Build"
      namespace        = "TFProdPlan"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["TFDevApplyArtifact"]
      output_artifacts = ["TFProdPlanArtifact"]
      version          = "1"

      configuration = {
        ProjectName = "${var.project}_prod_tfplan-project"
      }
    }

    action {
      category           = "Approval"
      name               = "approval"
      owner              = "AWS"
      provider           = "Manual"
      region             = var.region
      run_order          = 2
      version            = "1"
    }

  }

  stage {
    name = "TFProdApply"

    action {
      name             = "Build"
      namespace        = "TFProdApply"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["TFProdPlanArtifact"]
      output_artifacts = ["TFProdApplyArtifact"]
      version          = "1"

      configuration = {
        ProjectName = "${var.project}_prod_tfapply-project"
      }
    }

    action {
      category           = "Approval"
      name               = "approval"
      owner              = "AWS"
      provider           = "Manual"
      region             = var.region
      run_order          = 2
      version            = "1"
    }

  }
}

resource "aws_codestarconnections_connection" "github" {
  name          = "github-connection"
  provider_type = "GitHub"
}