output "codebuild" {
    value = module.iam_codebuild.codebuild
}

output "codepipeline" {
    value = module.iam_codebuild.codepipeline
}

output "ecs" {
    value = module.iam_ecs.ecs
}

output "ecs_prod" {
    value = module.iam_ecs_prod.ecs
}

output "s3_codebuild" {
    value = aws_s3_bucket.s3_codebuild
}

output "ecr" {
    value = aws_ecr_repository.repo
}

output "codecommit" {
    value = aws_codecommit_repository.repo
}

output "kms" {
    value = module.kms.key_arn
}