variable "aws_region" {
  description = "Região AWS (Learner Lab exige us-east-1)"
  type        = string
  default     = "us-east-1"
}

variable "bucket_prefix" {
  description = "Prefixo do nome do bucket S3 para o remote state (um sufixo aleatório é adicionado para garantir nome único globalmente)"
  type        = string
  default     = "tfstate-prova-devops"
}

variable "dynamodb_table_name" {
  description = "Nome da tabela DynamoDB usada para lock do state"
  type        = string
  default     = "tfstate-lock-prova-devops"
}
