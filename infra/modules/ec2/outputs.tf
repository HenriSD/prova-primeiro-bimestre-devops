output "instance_id" {
  description = "ID da instancia EC2"
  value       = aws_instance.api.id
}

output "public_ip" {
  description = "IP publico da EC2 (para acessar a API e via SSH)"
  value       = aws_instance.api.public_ip
}
