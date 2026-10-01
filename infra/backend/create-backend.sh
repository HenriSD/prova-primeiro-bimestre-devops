#!/bin/bash
# Cria o bucket S3 e a tabela DynamoDB para o remote state via AWS CLI,
# contornando a restrição de GetBucketObjectLockConfiguration do AWS Academy
# Learner Lab (a SCP da organização bloqueia essa chamada, que o provider
# Terraform faz automaticamente ao gerenciar um aws_s3_bucket).
#
# Uso: ./create-backend.sh

set -e

REGION="us-east-1"
BUCKET_NAME="tfstate-prova-devops-$(whoami)-$RANDOM"
TABLE_NAME="tfstate-lock-prova-devops"

echo "== Criando bucket S3: $BUCKET_NAME =="
aws s3api create-bucket --bucket "$BUCKET_NAME" --region "$REGION"

echo "== Habilitando versionamento =="
aws s3api put-bucket-versioning \
  --bucket "$BUCKET_NAME" \
  --versioning-configuration Status=Enabled

echo "== Habilitando encriptação (AES256) =="
aws s3api put-bucket-encryption \
  --bucket "$BUCKET_NAME" \
  --server-side-encryption-configuration '{"Rules":[{"ApplyServerSideEncryptionByDefault":{"SSEAlgorithm":"AES256"}}]}'

echo "== Bloqueando acesso público =="
aws s3api put-public-access-block \
  --bucket "$BUCKET_NAME" \
  --public-access-block-configuration BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true

echo "== Verificando/criando tabela DynamoDB: $TABLE_NAME =="
if aws dynamodb describe-table --table-name "$TABLE_NAME" --region "$REGION" >/dev/null 2>&1; then
  echo "Tabela já existe, pulando criação."
else
  aws dynamodb create-table \
    --table-name "$TABLE_NAME" \
    --attribute-definitions AttributeName=LockID,AttributeType=S \
    --key-schema AttributeName=LockID,KeyType=HASH \
    --billing-mode PAY_PER_REQUEST \
    --region "$REGION"

  echo "Aguardando tabela ficar ativa..."
  aws dynamodb wait table-exists --table-name "$TABLE_NAME" --region "$REGION"
fi

echo ""
echo "===================================================="
echo "Backend criado com sucesso!"
echo "Bucket S3:        $BUCKET_NAME"
echo "Tabela DynamoDB:  $TABLE_NAME"
echo ""
echo "Copie esses valores para infra/providers.tf (bloco backend \"s3\")"
echo "===================================================="