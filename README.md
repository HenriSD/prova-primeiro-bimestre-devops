# API de Reservas — TechNova

**Aluno:** Henri da Silva Despezzi
**RA:** 6325064

## Descrição

Projeto da Prova do Primeiro Bimestre de DevOps. API de Reservas (Node.js/Express + PostgreSQL),
containerizada com Docker/Compose e provisionada na AWS com Terraform modularizado
(VPC, Security Groups, EC2, RDS) usando remote state (S3 + DynamoDB).

## Estrutura

- `app/` — API de Reservas (Node.js/Express)
- `docker-compose.yml` — ambiente local (API + PostgreSQL)
- `infra/` — Terraform modularizado para AWS (Learner Lab)
- `relatorio.md` — relatório do processo com uso de IA

## Como rodar localmente

\`\`\`bash
cp .env.example .env
docker compose up --build
\`\`\`