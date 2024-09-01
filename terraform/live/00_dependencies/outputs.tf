output "codebuild" {
    value = module.iam_codebuild.codebuild
}

output "codepipeline" {
    value = module.iam_codebuild.codepipeline
}

output "ecs_dev" {
    value = module.iam_ecs_dev.ecs
}

output "ecs_qa" {
    value = module.iam_ecs_qa.ecs
}

output "ecs_prod" {
    value = module.iam_ecs_prod.ecs
}

output "s3_codebuild" {
    value = aws_s3_bucket.s3_codebuild
}

output "ecr_dev" {
    value = aws_ecr_repository.repo_dev
}

output "ecr_release" {
    value = aws_ecr_repository.repo_release
}

output "kms" {
    value = module.kms.key_arn
}