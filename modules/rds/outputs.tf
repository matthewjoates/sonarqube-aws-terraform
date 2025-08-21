output "db_endpoint" { 
    value = aws_db_instance.main.endpoint
    description = "The endpoint of the database"
}