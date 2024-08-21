variable "region" {
  type        = string
  description = "Region to deploy resources"
}

variable "env_name" {
  type        = string
  description = "Name of the environment to deploy"
}

variable "project" {
  type        = string
  description = "Name of the project"
}

variable "codepipeline_accountid" {
  type        = string
  description = "Codepipeline AWS Account Id"
}

variable "branch" {
  type        = string
  description = "Name of branch"
}

variable "repo_name" {
  type        = string
  description = "Name of ECR repo"
}

variable "s3_name" {
  type        = string
  description = "Name of bucket"
}

variable "iam_codebuild_arn" {
  type        = string
  description = "IAM Codebuild Role ARN"
}

variable "buildspec" {
  type        = string
  description = "Name of buildspec file"
}

variable "source_location" {
  type        = string
  description = "URL to git project"
}

variable "source_type" {
  type        = string
  description = "Source type"
}