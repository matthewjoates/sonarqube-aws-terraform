output "vpc_id"                      { value = aws_vpc.this.id }
output "public_subnet_az1_id"        { value = aws_subnet.public_az1.id }
output "public_subnet_az2_id"        { value = aws_subnet.public_az2.id }
output "public_security_group_id"    { value = aws_security_group.public.id }