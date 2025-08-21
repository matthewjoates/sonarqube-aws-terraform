data "aws_rds_orderable_db_instance" "postgres" {
  engine         = "postgres"
  engine_version = "17.4"
  license_model = "postgresql-license"
  preferred_instance_classes = ["db.t4g.medium"]
}