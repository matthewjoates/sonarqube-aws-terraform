variable "ec2_instance_name" { type = string }
variable "network_interface_subnet_id" {}
variable "network_interface_security_groups" {}
variable "target_port" {}
variable "user_data" { default = "" }

variable "instance_type" {
  type = string
  default = "t2.micro"
}

variable "aws_ami_owners" {
  default = ["amazon"]
  type = set(string)
}

variable "cpu_credits" {
  default = "standard"
  type = string
}

