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
    network_interface_id = var.network_interface_id
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

