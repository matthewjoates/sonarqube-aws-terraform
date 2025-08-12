locals {
  sonarqube_db_name     = "sonarqube"
  sonarqube_db_username = "sonaruser"
  sonarqube_jdbc_url    = "jdbc:postgresql://"
}

module "sonarqube_db" {
  depends_on                   = [module.developer_tooling_vpc]
  source                       = "./modules/rds"
  aws_db_instance_username     = local.sonarqube_db_username
  aws_db_instance_db_name      = local.sonarqube_db_name
  aws_db_parameter_group_name  = local.sonarqube_db_name
  subnet_ids                   = [module.developer_tooling_vpc.public_subnet_az1_id, module.developer_tooling_vpc.public_subnet_az2_id]
  vpc_id                       = module.developer_tooling_vpc.vpc_id
  db_port                      = 5432
  aws_source_security_group_id = module.developer_tooling_vpc.public_security_group_id
  db_url_prefix                = local.sonarqube_jdbc_url
  db_url_suffix                = local.sonarqube_db_name
  providers = {
    aws = aws.main
  }
}