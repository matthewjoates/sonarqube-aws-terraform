data "aws_region" "current" {}

locals {
  primary_az   = "${ data.aws_region.current.name }a"
  secondary_az = "${ data.aws_region.current.name }b"
}

variable "vpc_name" {}
variable "vpc_cidr_block" {}
variable "public_subnet_cidr_block_az1" {}
variable "public_subnet_cidr_block_az2" {}
variable "open_port" { type = number }

resource "aws_vpc" "this" {
  cidr_block = var.vpc_cidr_block
  enable_dns_hostnames = true
  enable_dns_support = true
  tags = {
    Name = var.vpc_name
  }
}                                                                  

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.public_subnet_cidr_block_az1
  map_public_ip_on_launch = true
  availability_zone       = local.primary_az
  tags = { Name = "${ var.vpc_name }-public-subnet-az1" }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.this.id
  tags = { Name = "${ var.vpc_name }-internet-gateway" }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = { Name = "${ var.vpc_name }-public-route-table" }
}

resource "aws_main_route_table_association" "public" {
  depends_on     = [aws_subnet.public]
  route_table_id = aws_route_table.public.id
  vpc_id         = aws_vpc.this.id
}

resource "aws_security_group" "public" {
  name = "${var.vpc_name}-public-security-group"
  vpc_id = aws_vpc.this.id
  timeouts {
    delete = "1m"
  }
}

resource "aws_security_group_rule" "egress" {
  type                     = "egress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  cidr_blocks              = ["0.0.0.0/0"]
  security_group_id        = aws_security_group.public.id
  description              = "Allow internet access"
}

resource "aws_security_group_rule" "ingress" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  cidr_blocks              = ["0.0.0.0/0"]
  security_group_id        = aws_security_group.public.id
  description              = "Allow access from anywhere"
}

resource "aws_security_group_rule" "ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.public.id
  description       = "Allow SSH"
}

resource "aws_security_group_rule" "ping" {
  type              = "ingress"
  from_port         = -1
  to_port           = -1
  protocol          = "icmp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.public.id
  description       = "Allow ICMP (ping)"
}

resource "aws_security_group_rule" "open_port" {
  type              = "ingress"
  from_port         = var.open_port
  to_port           = var.open_port
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.public.id
  description       = "Allow public access to application on port ${ var.open_port }"
}

resource "aws_ec2_instance_connect_endpoint" "public" {
  subnet_id   = aws_subnet.public.id
  security_group_ids = [aws_security_group.public.id]
  preserve_client_ip = true

  tags = {
    Name = "${ var.vpc_name }-public-ec2-instance-connect-endpoint"
  }
}

resource "aws_subnet" "public_az2" {
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.public_subnet_cidr_block_az2
  map_public_ip_on_launch = true
  availability_zone       = local.secondary_az
  tags = { Name = "${ var.vpc_name }-public-subnet-az2" }
}

resource "aws_route_table_association" "public_az2" {
  route_table_id = aws_route_table.public.id
  subnet_id = aws_subnet.public_az2.id
}

output "vpc_id"                      { value = aws_vpc.this.id }
output "public_subnet_az1_id"        { value = aws_subnet.public.id }
output "public_subnet_az2_id"        { value = aws_subnet.public_az2.id }
output "public_security_group_id"    { value = aws_security_group.public.id }
output "public_subnet_id"            { value = aws_subnet.public.id }