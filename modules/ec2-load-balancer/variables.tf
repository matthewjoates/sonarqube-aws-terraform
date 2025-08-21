variable "prefix" {
  description = "The prefix to use for all resources" 
}

variable "network_interface_security_groups" {
  description = "The security groups to associate with the network interface"
  type        = list(string)
}

variable "vpc_id" {
  description = "The VPC ID to launch resources into"
  type        = string
}

variable "target_port" {
  description = "The port on which the target group will listen"
  type        = number
}

variable "aws_instance_id" {
  description = "The ID of the EC2 instance to attach to the load balancer"
  type        = string
}