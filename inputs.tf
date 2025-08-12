variable "aws_region" {
  description = "The region used by the AWS provider"
  default     = "eu-west-1"
  type        = string
}

variable "aws_role_arn" {
  description = "The ARN of the AWS role to assume"
  type        = string
}

variable "root_domain_name" {
  description = "The root domain name for the infrastructure"
  type        = string
}

variable "root_domain_hz_id" {
  description = "The ID of the Route 53 hosted zone for the root domain"
  type        = string
}