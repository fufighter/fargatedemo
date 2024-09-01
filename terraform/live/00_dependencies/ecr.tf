resource "aws_ecr_repository" "repo_dev" {
  name                 = "${var.project}_dev"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

data "aws_iam_policy_document" "iam_policy_dev" {
  statement {
    sid    = "Codepipeline Cross Account Access"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = [
        module.iam_ecs_dev.ecs.arn
      ]
    }

    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:BatchGetImage",
      "ecr:DescribeImages",
      "ecr:DescribeRepositories",
      "ecr:GetDownloadUrlForLayer"
    ]
  }
}

resource "aws_ecr_repository_policy" "ecr_policy_dev" {
  depends_on = [
    module.iam_ecs_dev
  ]
  repository = aws_ecr_repository.repo_dev.name
  policy     = data.aws_iam_policy_document.iam_policy_dev.json
}


resource "aws_ecr_repository" "repo_release" {
  name                 = "${var.project}_release"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

data "aws_iam_policy_document" "iam_policy_release" {
  statement {
    sid    = "Codepipeline Cross Account Access"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = [
        module.iam_ecs_qa.ecs.arn,
        module.iam_ecs_prod.ecs.arn
      ]
    }

    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:BatchGetImage",
      "ecr:DescribeImages",
      "ecr:DescribeRepositories",
      "ecr:GetDownloadUrlForLayer"
    ]
  }
}

resource "aws_ecr_repository_policy" "ecr_policy_release" {
  depends_on = [
    module.iam_ecs_qa,
    module.iam_ecs_prod
  ]
  repository = aws_ecr_repository.repo_release.name
  policy     = data.aws_iam_policy_document.iam_policy_release.json
}