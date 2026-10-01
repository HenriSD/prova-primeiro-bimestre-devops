variable "aws_region" {
  description = "Região AWS (Learner Lab exige us-east-1)"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Nome do projeto, usado como prefixo nos nomes dos recursos"
  type        = string
  default     = "prova-devops-reservas"
}

variable "db_username" {
  description = "Usuario administrador do RDS"
  type        = string
  default     = "postgres"
  sensitive   = true
}

variable "db_password" {
  description = "Senha do RDS. Defina via terraform.tfvars (NAO versionado) ou variavel de ambiente TF_VAR_db_password."
  type        = string
  sensitive   = true
}

variable "db_name" {
  description = "Nome do banco de dados da API"
  type        = string
  default     = "reservas"
}

variable "ssh_allowed_cidr" {
  description = "CIDR autorizado a acessar a EC2 via SSH (ajuste para o seu IP: \"SEU.IP/32\")"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}
