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

variable "image" {
  type        = string
  description = "Name of the image"
}

variable "app_port" {
  type        = number
  description = "Application Port"
}

variable "iam_ecs_arn" {  
  type        = string
  description = "ECS Role Arn"
}

variable "vpc_id" {
  type        = string
  description = "VPC Id"
}

variable "public_subnets" {
  type        = list(string)
  description = "List of Public Subnets"
}