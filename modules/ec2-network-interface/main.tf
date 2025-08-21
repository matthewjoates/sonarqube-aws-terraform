resource "aws_network_interface" "this" {
  subnet_id       = var.network_interface_subnet_id
  security_groups = var.network_interface_security_groups
  tags = {
    Name = "${ var.prefix }-network-interface"
  }
}

resource "aws_eip" "this" {
  domain   = "vpc"
}

resource "aws_eip_association" "this" {
  allocation_id        = aws_eip.this.id
  network_interface_id = aws_network_interface.this.id
}