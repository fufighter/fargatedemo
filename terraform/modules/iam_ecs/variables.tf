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

variable "key_arn" {
  type        = string
  description = "KMS Key Arn"
}

variable "s3_arn" {
  type        = string
  description = "Codepipeline S3 Arn"
}