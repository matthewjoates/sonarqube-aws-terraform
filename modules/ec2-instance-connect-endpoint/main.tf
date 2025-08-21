resource "aws_ec2_instance_connect_endpoint" "public" {
  subnet_id   = var.aws_subnet_id
  security_group_ids = [var.aws_security_group_id]
  preserve_client_ip = true

  tags = {
    Name = "${ var.prefix }-public-ec2-instance-connect-endpoint"
  }
}