variable "db_port"                           {}
variable "vpc_id"                            {}
variable "aws_source_security_group_id"      {}
variable "db_url_prefix"                     { default = "" }
variable "db_url_suffix"                     { default = "" }
variable "aws_db_instance_username"          { default = "postgres" }
variable "aws_db_instance_db_name"           { default = "postgres" }
variable "aws_db_parameter_group_name"       { default = "postgres" }
variable "aws_db_instance_allocated_storage" { default = 20 }
variable "subnet_ids"                        { type = set(string) }

data "aws_rds_orderable_db_instance" "postgres" {
  engine         = "postgres"
  engine_version = "17.4"
  license_model = "postgresql-license"
  preferred_instance_classes = ["db.t4g.medium"]
}

resource "aws_db_parameter_group" "main" {
  name   = "${var.aws_db_parameter_group_name}-17"
  family = "postgres17"

  parameter {
    name  = "log_connections"
    value = "1"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "random_password" "db_password" {
  length           = 16
  special         = true
  override_special = "!@#%^&*()-_=+[]{}<>:?"
}

resource "aws_ssm_parameter" "db_password" {
  name        = "/${var.aws_db_instance_db_name}/database/password"
  type        = "SecureString"
  value       = random_password.db_password.result
}

resource "aws_ssm_parameter" "db_url" {
  name        = "/sonarqube/database/url"
  type        = "String"
  value       = "${ var.db_url_prefix }${ aws_db_instance.main.endpoint }/${ var.db_url_suffix }"
}

resource "aws_ssm_parameter" "db_username" {
  name        = "/sonarqube/database/username"
  type        = "String"
  value       = var.aws_db_instance_username
}

resource "aws_db_subnet_group" "subnet_group" {
  subnet_ids = var.subnet_ids
  name = "${ var.aws_db_instance_db_name }-subnet-group"
}

resource "aws_db_instance" "main" {
  allocated_storage           = var.aws_db_instance_allocated_storage
  allow_major_version_upgrade = true
  identifier                  = "${ var.aws_db_instance_db_name }-main-database"
  db_name                     = var.aws_db_instance_db_name
  engine                      = data.aws_rds_orderable_db_instance.postgres.engine
  engine_version              = data.aws_rds_orderable_db_instance.postgres.engine_version
  instance_class              = data.aws_rds_orderable_db_instance.postgres.instance_class
  username                    = var.aws_db_instance_username
  password                    = aws_ssm_parameter.db_password.value
  parameter_group_name        = aws_db_parameter_group.main.name
  skip_final_snapshot         = true
  apply_immediately           = true
  db_subnet_group_name        = aws_db_subnet_group.subnet_group.name
  vpc_security_group_ids      = [aws_security_group.rds.id]
  port                        = var.db_port
}

resource "aws_security_group" "rds" {
  name   = "${ var.aws_db_instance_db_name }-database-security-group"
  vpc_id = var.vpc_id
  description = "Security Group attached to ${ var.aws_db_instance_db_name } to securely allow EC2 instances in security group ${ var.aws_source_security_group_id } to connect to the database."
}

resource "aws_security_group_rule" "ec2_to_db" {
  type        = "ingress"
  from_port   = var.db_port
  to_port     = var.db_port
  protocol    = "tcp"
  security_group_id = aws_security_group.rds.id
  source_security_group_id = var.aws_source_security_group_id
  description = "Allow connection to ${ var.aws_db_instance_db_name }"
}

output "db_endpoint" { value = aws_db_instance.main.endpoint }