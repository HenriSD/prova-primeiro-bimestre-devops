output "endpoint" {
  description = "Endpoint do RDS (host:porta) para a API se conectar"
  value       = aws_db_instance.postgres.endpoint
}

output "address" {
  description = "Endereco (host) do RDS, sem a porta"
  value       = aws_db_instance.postgres.address
}

output "db_name" {
  description = "Nome do banco de dados"
  value       = aws_db_instance.postgres.db_name
}
