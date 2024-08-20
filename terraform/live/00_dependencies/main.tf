data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

provider "aws" {
  region = var.region
}

provider "aws" {
  alias  = "prod"
  region = var.region
  assume_role {
    role_arn = "arn:aws:iam::${var.accountid_prod}:role/terraform-execute"
  }  
}
