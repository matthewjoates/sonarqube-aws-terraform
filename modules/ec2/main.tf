data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

data "aws_ami" "ami" {
  most_recent = true
  owners = var.aws_ami_owners

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "tls_private_key" "my_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {
  key_name   = "${ var.ec2_instance_name }-key"
  public_key = tls_private_key.my_key.public_key_openssh
}

resource "aws_ssm_parameter" "ssh_private_key" {
  name  = "/${ var.ec2_instance_name }/server/ssh-private-key"
  type  = "SecureString"
  value = tls_private_key.my_key.private_key_pem
}


resource "aws_iam_role" "example" {
  name = "EC2SSMRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_policy" "ssm_policy" {
  name        = "SSMParameterAccess"
  description = "Allow EC2 to read SSM parameters"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = [
        "ssm:GetParameter",
        "ssm:GetParameters",
        "ssm:GetParametersByPath"
      ]
      Effect   = "Allow"
      Resource = "arn:aws:ssm:${ data.aws_region.current.name }:${ data.aws_caller_identity.current.account_id }:parameter/sonarqube/*"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "attach_ssm" {
  role       = aws_iam_role.example.name
  policy_arn = aws_iam_policy.ssm_policy.arn
}

resource "aws_iam_instance_profile" "example" {
  name = "EC2InstanceProfile"
  role = aws_iam_role.example.name
}

resource "aws_instance" "instance" {
  ami                  = data.aws_ami.ami.id
  iam_instance_profile = aws_iam_instance_profile.example.name
  instance_type        = var.instance_type
  key_name             = aws_key_pair.generated_key.key_name
  user_data            = var.user_data

  network_interface {
    network_interface_id = aws_network_interface.public.id
    device_index         = 0
  }

  credit_specification {
    cpu_credits = var.cpu_credits
  }

  root_block_device {
    volume_size = 20
  }

  tags = {
    Name = var.ec2_instance_name
  }
}

resource "aws_network_interface" "public" {
  subnet_id       = var.network_interface_subnet_id
  security_groups = var.network_interface_security_groups
  tags = {
    Name = "${ var.ec2_instance_name }-network-interface"
  }
}

resource "aws_eip" "this" {
  domain   = "vpc"
}

resource "aws_eip_association" "sonarqube" {
  allocation_id        = aws_eip.this.id
  network_interface_id = aws_network_interface.public.id
}


variable "vpc_id" {}
data "aws_subnets" "public" {
  filter {
    name = "vpc-id"
    values = [var.vpc_id]
  }
}

resource "aws_lb" "alb" {
  name               = "${ var.ec2_instance_name }-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = var.network_interface_security_groups
  subnets            = data.aws_subnets.public.ids
}

resource "aws_lb_target_group" "tg" {
  name        = "${var.ec2_instance_name}-tg"
  port        = var.target_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "instance"

  health_check {
    path                = "/"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
    matcher             = "200-399"
  }

  deregistration_delay = 30
  slow_start           = 30
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}

variable "certificate_arn" {}
resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 443
  protocol         = "HTTPS"
  ssl_policy       = "ELBSecurityPolicy-2016-08"
  certificate_arn  = var.certificate_arn

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}

resource "aws_lb_target_group_attachment" "target" {
  target_group_arn = aws_lb_target_group.tg.arn
  target_id        = aws_instance.instance.id
}

output "instance_id"   { value = aws_instance.instance.id }
output "elastic_ip"    { value = aws_eip.this.public_ip }