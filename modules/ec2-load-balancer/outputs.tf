output "lb_arn" {
  value = aws_lb.alb.arn
  description = "The ARN of the load balancer"
}

output "tg_arn" {
  value = aws_lb_target_group.tg.arn
  description = "The ARN of the target group"
}