module "sonarqube_https_certificate" {
  source         = "./modules/acm"
  domain_name    = concat("sonarqube.", var.root_domain_name)
  hosted_zone_id = var.root_domain_hz_id
  providers = {
    aws = aws.main
  }
}