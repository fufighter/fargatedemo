resource "aws_iam_role" "iam_role_ecs" {
  name                = "${var.project}_ecs_${var.env_name}"
  assume_role_policy  = data.aws_iam_policy_document.iam_assume_ecs.json
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceRole",
    "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
  ]
}

resource "aws_iam_role_policy" "iam_policy_ecs" {
  role   = aws_iam_role.iam_role_ecs.id
  policy = data.aws_iam_policy_document.ecs.json
}

data "aws_iam_policy_document" "iam_assume_ecs" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = [
        "ecs-tasks.amazonaws.com",
        "codepipeline.amazonaws.com"
      ]
    }

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${var.codepipeline_accountid}:root"]
    }

    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "ecs" {
  statement {
    effect = "Allow"
    actions = [
      "s3:Get*"
    ]
    resources = [
      "${var.s3_arn}/*",
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "s3:ListBucket"
    ]
    resources = [
      var.s3_arn
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "iam:PassRole",
      "ecs:*",
      "ecr:*"
    ]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "kms:DescribeKey",
      "kms:GenerateDataKey",
      "kms:Encrypt",
      "kms:ReEncrypt",
      "kms:Decrypt"
    ]
    resources = [
      var.key_arn
    ]
  }
}
