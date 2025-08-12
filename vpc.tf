# See /utils/delete_guardduty_vpc_config.sh before destroying module.
module "developer_tooling_vpc" {
  source = "./modules/vpc"
  providers = {
    aws = aws.main
  }
  vpc_name                     = "developer-tooling-vpc"
  vpc_cidr_block               = "172.16.0.0/16"
  public_subnet_cidr_block_az1 = "172.16.20.0/24"
  public_subnet_cidr_block_az2 = "172.16.21.0/24"
  open_port                    = local.sonarqube_port
}