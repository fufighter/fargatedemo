variable "region" {
  type        = string
  description = "Region to deploy resources"
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

variable "timeout" {
  type        = number
  description = "CodeBuild timeout in minutes"
  default     = 15
}