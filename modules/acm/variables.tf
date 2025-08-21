variable "domain_name" {
    type = string
    description = "The domain name for the ACM certificate"
}

variable "hosted_zone_id" {
    type = string
    description = "The ID of the hosted zone for the domain"
}

variable "aws_load_balancer_arn" {
    type = string
    description = "The ARN of the AWS load balancer"
}

variable "aws_load_balancer_target_group_arn" {
    type = string
    description = "The ARN of the AWS load balancer target group"
}