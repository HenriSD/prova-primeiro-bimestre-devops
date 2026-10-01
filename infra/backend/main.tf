terraform {
  required_version = ">= 1.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.41.0"
    }
  }
  # O bucket S3 e a tabela DynamoDB deste backend foram criados via AWS CLI
  # (script create-backend.sh), não pelo Terraform, devido a uma restrição do
  # AWS Academy Learner Lab: a SCP da organização bloqueia explicitamente a
  # chamada s3:GetBucketObjectLockConfiguration, que o provider do Terraform
  # executa automaticamente ao gerenciar um recurso aws_s3_bucket.
  # Veja infra/backend/create-backend.sh e relatorio.md (Questão 3) para detalhes.
}

provider "aws" {
  region = var.aws_region
}