data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

data "aws_subnets" "public" {
  filter {
    name = "vpc-id"
    values = [var.vpc_id]
  }
}