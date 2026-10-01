# Relatório do Processo — Prova do Primeiro Bimestre (DevOps)

**Aluno:** Henri da Silva Despezzi
**RA:** 6325064
**Ferramenta de IA utilizada:** Claude (Anthropic)

---

## Questão 1 — A Jornada Completa (Aulas 01 a 07)

Segui a ordem sugerida pelo próprio enunciado: Git → aplicação → Docker → Docker Compose →
Terraform, e só no final a infraestrutura completa na AWS. Essa ordem fez sentido porque cada
camada depende da anterior estar funcionando — não adianta provisionar EC2 e RDS na nuvem se a
aplicação ainda nem roda localmente ou se não sei se o Dockerfile builda corretamente.

Comecei criando o repositório e o `.gitignore` (Aula 01), já pensando em quais arquivos nunca
poderiam ser versionados (`.env`, `.tfstate`, chaves `.pem`). Em seguida construí a API de
Reservas em Node/Express com conexão real ao PostgreSQL via variáveis de ambiente — decisão
importante, porque esse mesmo código, sem alterar uma linha, funcionou tanto no Docker Compose
local quanto no RDS na nuvem, só trocando `DB_HOST`. Testei o CRUD manualmente com `curl` antes
de seguir, subindo um Postgres avulso via Docker para validar cada rota (POST, GET, GET/:id,
PUT, DELETE) antes de empacotar qualquer coisa.

A Aula 01 (Docker) apareceu no Dockerfile multi-stage com usuário não-root — separei o estágio
de instalação de dependências do estágio final, para a imagem de produção não carregar
ferramentas de build desnecessárias. A Aula 02 (Compose) apareceu ao orquestrar API + PostgreSQL
juntos, com healthcheck no banco e `depends_on: condition: service_healthy`, para a API nunca
tentar subir antes do banco aceitar conexões — testei isso de verdade derrubando e subindo o
ambiente várias vezes para confirmar que os dados persistiam no volume nomeado.

As Aulas 03 a 06 (Terraform, IAM, VPC, EC2, RDS, módulos, remote state) formaram a parte mais
longa: modularizei em `vpc`, `security-group`, `ec2` e `rds`, compondo tudo em um `main.tf` onde
o output de um módulo alimenta o input do outro (por exemplo, os IDs das subnets privadas da VPC
alimentam o `db_subnet_group` do módulo RDS). Usei remote state com backend S3 + DynamoDB,
embora tenha precisado adaptar a forma de criar esse backend por conta de uma restrição
específica do Learner Lab (detalho na Questão 3). Por fim, apliquei a infraestrutura de verdade
na AWS, subi a API dentro da EC2 conectando no RDS real, testei via `curl` externo, capturei as
evidências e destruí tudo em seguida.

## Questão 2 — O Processo com IA como Copiloto

Usei o Claude (Anthropic) como copiloto durante praticamente todo o processo, em uma conversa
contínua, não isolada por partes. O fluxo que funcionou melhor foi: eu descrevia o objetivo de
cada parte do enunciado, a IA sugeria a estrutura de arquivos e o código, e eu testava
imediatamente antes de prosseguir, nunca empilhando uma parte em cima de outra sem validar a
anterior.

Um ponto interessante é que, antes mesmo de começar a codificar, pedi para a IA analisar o
enunciado em busca de possíveis pegadinhas técnicas (como a restrição de não criar recursos IAM
no Learner Lab, ou o problema de "ovo e galinha" do remote state). Isso me ajudou a já escrever
o código certo desde a primeira tentativa em vários pontos, em vez de descobrir o erro só na hora
de aplicar.

A IA gerou bem a estrutura geral do CRUD, do Dockerfile multi-stage e dos módulos Terraform —
código sintaticamente correto e seguindo boas práticas (usuário não-root no container, princípio
de menor privilégio nos Security Groups, por exemplo). Onde precisei corrigir ou intervir de
verdade foi nos problemas específicos do ambiente AWS Academy, que só apareceram ao rodar de
verdade: o provider do Terraform tentando ler a configuração de Object Lock do bucket S3 (bloqueada
pela política da organização do Lab), e o RDS exigindo conexão SSL, que o código inicial não
previa. Nesses casos, colei o erro real do terminal e fomos iterando até achar uma solução
funcional — nenhuma dessas correções veio "pronta" de primeira, foi tentativa, erro e ajuste.

Comparando com fazer tudo manualmente: a IA economizou bastante tempo na parte de
(estrutura de pastas, sintaxe do Terraform, validações de rota), que eu teria que consultar
documentação para lembrar de cor. Por outro lado, ela não tem como prever as particularidades
específicas de um ambiente restrito como o Learner Lab — isso só apareceu testando de verdade
contra a AWS, e exigiu interpretação minha de cada erro antes de aceitar qualquer correção
sugerida.

## Questão 3 — Infraestrutura, Segurança e o Learner Lab

A arquitetura provisionada tem uma VPC própria (`10.0.0.0/16`) com 2 subnets públicas e 2
privadas, distribuídas em duas zonas de disponibilidade diferentes (`us-east-1a` e `us-east-1b`).
A EC2 com a API fica em uma subnet pública, com IP público e Security Group liberando apenas as
portas 22 (SSH) e 3000 (API). O RDS PostgreSQL fica em subnet privada, sem IP público
(`publicly_accessible = false`), com storage encriptado, e seu Security Group libera a porta 5432
**apenas** a partir do Security Group da EC2 — não de nenhum CIDR aberto. Essa separação existe
porque o banco de dados não precisa (e não deve) ser acessível diretamente da internet; só a
aplicação que já está dentro da VPC deveria conversar com ele, reduzindo a superfície de ataque.

Sobre o `LabInstanceProfile`: como o Learner Lab não permite criar roles ou instance profiles
IAM próprios, usei um `data source` no Terraform (`data "aws_iam_instance_profile"`) para apenas
referenciar o instance profile que já existe no Lab, em vez de tentar criar um novo recurso
IAM (o que teria falhado com erro de permissão).

O Learner Lab exigiu vários ajustes em relação ao que foi ensinado de forma genérica: primeiro,
as credenciais são temporárias e expiram em poucas horas (incluindo `aws_session_token`), então
precisei renovar o `~/.aws/credentials` mais de uma vez durante o processo. Segundo, uma SCP
(Service Control Policy) da organização do Lab bloqueia explicitamente a chamada
`s3:GetBucketObjectLockConfiguration`, que o provider do Terraform executa automaticamente
sempre que gerencia um recurso `aws_s3_bucket` isso impediu o Terraform de criar o bucket do
remote state diretamente, mesmo testando duas versões diferentes do provider AWS. A solução foi
criar o bucket S3 e a tabela DynamoDB via AWS CLI (documentei isso em um script
`create-backend.sh`), deixando-os fora do controle do Terraform, só usados como backend. Terceiro,
o RDS do Lab exige conexão SSL por padrão, algo que meu código inicial não previa, precisei
ajustar a configuração do pool de conexões do PostgreSQL para habilitar SSL condicionalmente
quando rodando na nuvem.

## Questão 4 — Validação e Responsabilidade

Antes de rodar qualquer `terraform apply`, apliquei um checklist: conferir que nenhum recurso
`aws_iam_*` aparecia no `terraform plan` (só `data sources`); verificar que a regra do Security
Group do RDS usava `security_groups` (referência a outro SG) e não `cidr_blocks` abertos;
confirmar que o RDS tinha `publicly_accessible = false` e `storage_encrypted = true`; e revisar
a contagem total de recursos no plano para ver se batia com o que eu esperava (17 recursos na
primeira aplicação). Só depois dessa revisão manual do `plan` eu seguia para o `apply`.

Validei que a infraestrutura estava correta testando de ponta a ponta, não só confiando no
código: subi a API dentro da própria EC2, conectei de verdade no endpoint do RDS, e testei as
rotas CRUD via `curl` tanto de dentro da instância quanto de fora, pela internet pública. Isso
confirmou, na prática, que o Security Group estava configurado certo (a API conseguiu alcançar o
banco, mas o banco continua inacessível diretam, fora da VPC).

Se eu tivesse aceitado o código gerado pela IA sem revisar ou testar, o risco mais concreto seria
rodar `apply` com algum recurso IAM sendo criado (o que teria falhado e consumido tempo), ou pior,
deixar alguma regra de Security Group mais aberta do que deveria (por exemplo, `cidr_blocks =
["0.0.0.0/0"]` na porta do banco), o que exporia o RDS a qualquer IP da internet — um erro de
segurança real, não só acadêmico. Também corri esse risco de forma mais sutil: em um momento,
quase commitei a chave SSH privada (`infra/chave-prova`) para o Git por uma falha no
`.gitignore` — só percebi revisando o `git status` com atenção antes do commit, o que reforça que
revisar cada passo, mesmo os aparentemente simples, é parte do trabalho.

A evolução ao longo do bimestre — Git, depois Docker, depois Terraform e módulos — me preparou
para usar IA com mais responsabilidade porque cada etapa ensinou um jeito diferente de validar
antes de confiar: no Git, aprendi a revisar `git status`/`git diff` antes de cada commit; no
Docker, a testar containers isoladamente antes de compor; no Terraform, a sempre ler o `plan`
antes do `apply`. Usar a IA como copiloto não elimina essa responsabilidade — só muda de onde vem
o código que preciso revisar.