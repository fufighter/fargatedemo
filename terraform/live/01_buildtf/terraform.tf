#######################################
# Terraform backend configuration
#######################################
terraform {
  ### Required Terraform version
  required_version = "~> 1.5.5"
  ### Set backend storage
  backend "s3" {
    bucket         = "afu-terraform-state-backend"
    dynamodb_table = "afu-terraform-state-backend"
    region         = "us-east-1"
    # change the key to match the name of the account in insite
    key = "afu/codebuildtf/terraform.tfstate"
  }
  ### Set provider settings
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.62.0"
    }
  }
}
