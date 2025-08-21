variable "vpc_name" {
    type = string
    description = "The name of the VPC"
}

variable "vpc_cidr_block" {
    type = string
    description = "The CIDR block for the VPC"
}

variable "public_subnet_cidr_block_az1" {
    type = string
    description = "The CIDR block for the public subnet in availability zone 1"
}

variable "public_subnet_cidr_block_az2" {
    type = string
    description = "The CIDR block for the public subnet in availability zone 2"
}

variable "open_port" {
    type = number
    description = "The port to open in the security group"
}