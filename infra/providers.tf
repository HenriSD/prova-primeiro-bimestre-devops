terraform {
  required_version = ">= 1.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Backend remoto (S3 + DynamoDB). Os valores de "bucket" e "dynamodb_table" vêm
  # dos outputs do diretório infra/backend/ (criado ANTES deste, com state local).
  #
  # IMPORTANTE: o bloco "backend" não aceita variáveis, então os valores abaixo
  # precisam ser preenchidos manualmente com o que o `terraform output` do
  # infra/backend/ retornar. Substitua os placeholders antes de rodar `terraform init`.
  backend "s3" {
    bucket         = "tfstate-prova-devops-usuario-26318"
    key            = "prova-devops/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "tfstate-lock-prova-devops"
    encrypt        = true
  }
}

provider "aws" {
  region = var.aws_region
}
