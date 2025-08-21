variable "ec2_instance_name" { 
  type = string 
  description = "The name of the EC2 instance"
}

variable "user_data" { 
  default = "" 
  description = "User data to provide when launching the instance"
}

variable "instance_type" {
  type = string
  default = "t2.micro"
  description = "The instance type to use for the EC2 instance"
}

variable "aws_ami_owners" {
  default = ["amazon"]
  type = set(string)
  description = "The owners of the AMIs to search for"
}

variable "cpu_credits" {
  default = "standard"
  type = string
  description = "The CPU credits to use for the instance"
}

variable "network_interface_id" {
  type        = string
  description = "The ID of the network interface to attach to the instance"
}