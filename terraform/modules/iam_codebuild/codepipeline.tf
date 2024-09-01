resource "aws_iam_role" "iam_role_codepipeline" {
  name               = "${var.project}_pipeline"
  assume_role_policy = data.aws_iam_policy_document.iam_assume_codepipeline.json
}

resource "aws_iam_role_policy" "iam_policy_codepipeline" {
  role   = aws_iam_role.iam_role_codepipeline.id
  policy = data.aws_iam_policy_document.codepipeline.json
}

data "aws_iam_policy_document" "iam_assume_codepipeline" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["codepipeline.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "codepipeline" {
  statement {
    effect = "Allow"
    actions = [
      "codebuild:BatchGetBuilds",
      "codebuild:StartBuild",
    ]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "codecommit:*"
    ]
    resources = ["*"]
  }

  statement {
    effect = "Allow"

    actions = [
      "iam:PassRole",
      "sts:AssumeRole",
      "codestar-connections:UseConnection",
      "cloudwatch:*",
      "kms:*",
      "s3:*",
      "ecs:*",
      "ecr:*"
    ]
    resources = ["*"]
  }
}
