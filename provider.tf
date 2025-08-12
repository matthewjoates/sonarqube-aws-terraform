locals {
  default_tags = {
    deployment_repo = "sonarqube"
    managed_by      = "Terraform"
  }
}

provider "aws" {
  alias  = "main"
  region = var.aws_region
  assume_role {
    role_arn = var.aws_role_arn
  }
  default_tags {
    tags = local.default_tags
  }
}