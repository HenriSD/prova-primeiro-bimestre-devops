variable "project_name" {
  description = "Nome do projeto, usado como prefixo nos nomes dos recursos"
  type        = string
}

variable "vpc_id" {
  description = "ID da VPC onde os Security Groups serao criados"
  type        = string
}

variable "ssh_allowed_cidr" {
  description = "CIDR(s) autorizados a acessar a EC2 via SSH. Ajuste para o seu IP (ex: \"SEU.IP.AQUI/32\") antes de aplicar, em vez de deixar aberto."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "tags" {
  description = "Tags comuns aplicadas a todos os recursos"
  type        = map(string)
  default     = {}
}
