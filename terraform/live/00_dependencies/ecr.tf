resource "aws_ecr_repository" "repo" {
  name                 = "${var.project}"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

data "aws_iam_policy_document" "example" {
  statement {
    sid    = "Codepipeline Cross Account Access"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = [
        module.iam_ecs_dev.ecs.arn,
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

resource "aws_ecr_repository_policy" "example" {
  depends_on = [
    module.iam_ecs_dev,
    module.iam_ecs_prod
  ]
  repository = aws_ecr_repository.repo.name
  policy     = data.aws_iam_policy_document.example.json
}