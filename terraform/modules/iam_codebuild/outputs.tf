output "codebuild" {
    value = aws_iam_role.iam_role_codebuild
}

output "codepipeline" {
    value = aws_iam_role.iam_role_codepipeline
}