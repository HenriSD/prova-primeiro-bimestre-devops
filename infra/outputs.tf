output "ec2_public_ip" {
  description = "IP publico da EC2 - acesse a API em http://IP:3000"
  value       = module.ec2.public_ip
}

output "rds_endpoint" {
  description = "Endpoint do RDS (host:porta) - use para configurar DB_HOST/DB_PORT da API"
  value       = module.rds.endpoint
}

output "api_url" {
  description = "URL completa para acessar a API"
  value       = "http://${module.ec2.public_ip}:3000"
}

output "vpc_id" {
  description = "ID da VPC criada"
  value       = module.vpc.vpc_id
}
