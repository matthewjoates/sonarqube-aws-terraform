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