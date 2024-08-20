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

variable "accountid_prod" {
  type        = string
  description = "Prod AWS Account ID"
}

variable "accountid_qa" {
  type        = string
  description = "Qa AWS Account ID"
}