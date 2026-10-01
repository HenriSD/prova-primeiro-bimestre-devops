variable "project_name" {
  description = "Nome do projeto, usado como prefixo nos nomes dos recursos"
  type        = string
}

variable "instance_class" {
  description = "Classe da instancia RDS"
  type        = string
  default     = "db.t3.micro"
}

variable "private_subnet_ids" {
  description = "IDs das subnets privadas para o DB Subnet Group"
  type        = list(string)
}

variable "security_group_id" {
  description = "ID do Security Group a ser associado ao RDS"
  type        = string
}

variable "db_name" {
  description = "Nome do banco de dados inicial"
  type        = string
  default     = "reservas"
}

variable "db_username" {
  description = "Usuario administrador do banco"
  type        = string
  default     = "postgres"
  sensitive   = true
}

variable "db_password" {
  description = "Senha do usuario administrador do banco"
  type        = string
  sensitive   = true
}

variable "tags" {
  description = "Tags comuns aplicadas a todos os recursos"
  type        = map(string)
  default     = {}
}
