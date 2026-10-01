variable "project_name" {
  description = "Nome do projeto, usado como prefixo nos nomes dos recursos"
  type        = string
}

variable "vpc_cidr" {
  description = "Bloco CIDR da VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "Blocos CIDR das subnets públicas (uma por AZ)"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "Blocos CIDR das subnets privadas (uma por AZ)"
  type        = list(string)
  default     = ["10.0.101.0/24", "10.0.102.0/24"]
}

variable "tags" {
  description = "Tags comuns aplicadas a todos os recursos"
  type        = map(string)
  default     = {}
}
