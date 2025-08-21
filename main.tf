locals {
  sonarqube_db_name     = "sonarqube"
  sonarqube_db_username = "sonaruser"
  sonarqube_jdbc_url    = "jdbc:postgresql://"
  sonarqube_tcp_port    = 9000
  sonarqube_init_script = file("./utils/init-sq.sh")
}

module "sonarqube_vpc" {
  source = "./modules/vpc"
  providers = {
    aws = aws.main
  }
  vpc_name                     = "sonarqube-vpc"
  vpc_cidr_block               = "172.16.0.0/16"
  public_subnet_cidr_block_az1 = "172.16.20.0/24"
  public_subnet_cidr_block_az2 = "172.16.21.0/24"
  open_port                    = local.sonarqube_tcp_port
}

module "sonarqube_db" {
  depends_on                   = [module.sonarqube_vpc]
  source                       = "./modules/rds"
  aws_db_instance_username     = local.sonarqube_db_username
  aws_db_instance_db_name      = local.sonarqube_db_name
  aws_db_parameter_group_name  = local.sonarqube_db_name
  subnet_ids                   = [module.sonarqube_vpc.public_subnet_az1_id, module.sonarqube_vpc.public_subnet_az2_id]
  vpc_id                       = module.sonarqube_vpc.vpc_id
  db_port                      = 5432
  aws_source_security_group_id = module.sonarqube_vpc.public_security_group_id
  db_url_prefix                = local.sonarqube_jdbc_url
  db_url_suffix                = local.sonarqube_db_name
  providers = {
    aws = aws.main
  }
}

module "sonarqube_network_interface" {
  source                            = "./modules/ec2-network-interface"
  network_interface_subnet_id       = module.sonarqube_vpc.public_subnet_id
  network_interface_security_groups = [module.sonarqube_vpc.public_security_group_id]
  prefix                            = "sonarqube"
  providers = {
    aws = aws.main
  }
}

module "sonarqube_server" {
  depends_on           = [module.sonarqube_db]
  source               = "./modules/ec2-instance"
  ec2_instance_name    = "sonarqube"
  instance_type        = "t3.medium"
  user_data            = local.sonarqube_init_script
  network_interface_id = module.sonarqube_network_interface.network_interface_id
  providers = {
    aws = aws.main
  }
}

module "sonarqube_load_balancer" {
  source                            = "./modules/ec2-load-balancer"
  prefix                            = "sonarqube"
  network_interface_security_groups = [module.sonarqube_vpc.public_security_group_id]
  vpc_id                            = module.sonarqube_vpc.vpc_id
  target_port                       = local.sonarqube_tcp_port
  aws_instance_id                   = module.sonarqube_server.instance_id
  providers = {
    aws = aws.main
  }
}

module "sonarqube_https_certificate" {
  source                             = "./modules/acm"
  aws_load_balancer_arn              = module.sonarqube_load_balancer.lb_arn
  aws_load_balancer_target_group_arn = module.sonarqube_load_balancer.tg_arn
  domain_name                        = "sonarqube.${var.root_domain_name}"
  hosted_zone_id                     = var.root_domain_hz_id
  providers = {
    aws = aws.main
  }
  count = var.create_https_certificate ? 1 : 0
}