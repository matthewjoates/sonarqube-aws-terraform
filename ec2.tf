locals {
  amazon_linux_user_data = file("./modules/ec2/scripts/init.sh")
  sonarqube_port         = 9000
}

module "sonarqube_server" {
  depends_on                        = [module.sonarqube_db]
  source                            = "./modules/ec2"
  ec2_instance_name                 = "sonarqube"
  instance_type                     = "t3.medium"
  user_data                         = local.amazon_linux_user_data
  network_interface_security_groups = [module.developer_tooling_vpc.public_security_group_id]
  network_interface_subnet_id       = module.developer_tooling_vpc.public_subnet_id
  vpc_id                            = module.developer_tooling_vpc.vpc_id
  target_port                       = local.sonarqube_port
  certificate_arn                   = module.sonarqube_https_certificate.certificate_arn
  providers = {
    aws = aws.main
  }
}