variable "project_name" {
  description = "Nome do projeto, usado como prefixo nos nomes dos recursos"
  type        = string
}

variable "instance_type" {
  description = "Tipo da instancia EC2"
  type        = string
  default     = "t2.micro"
}

variable "public_subnet_id" {
  description = "ID da subnet publica onde a EC2 sera lancada"
  type        = string
}

variable "security_group_id" {
  description = "ID do Security Group a ser associado a EC2"
  type        = string
}

variable "instance_profile_name" {
  description = "Nome do instance profile JA EXISTENTE no Learner Lab (nao criar um novo)"
  type        = string
  default     = "LabInstanceProfile"
}

variable "public_key_path" {
  description = "Caminho para o arquivo de chave publica SSH (.pub)"
  type        = string
}

variable "tags" {
  description = "Tags comuns aplicadas a todos os recursos"
  type        = map(string)
  default     = {}
}