# IMPORTANTE (AWS Academy Learner Lab): o Lab NAO permite criar roles/instance profiles IAM.
# Por isso usamos "data" para REFERENCIAR o LabInstanceProfile ja existente,
# em vez de "resource aws_iam_instance_profile" (que falharia com AccessDenied).
data "aws_iam_instance_profile" "lab_profile" {
  name = var.instance_profile_name
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_key_pair" "api" {
  key_name   = "${var.project_name}-key"
  public_key = file(var.public_key_path)

  tags = merge(var.tags, {
    Name = "${var.project_name}-key"
  })
}

resource "aws_instance" "api" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type
  subnet_id              = var.public_subnet_id
  vpc_security_group_ids = [var.security_group_id]
  iam_instance_profile   = data.aws_iam_instance_profile.lab_profile.name
  key_name               = aws_key_pair.api.key_name

  # User data: instala Docker e Docker Compose, prepara a maquina para rodar a API.
  # A imagem da API deve ser enviada/pullada manualmente ou via pipeline a parte
  # (fora do escopo do Terraform em si).
  user_data = <<-EOF
    #!/bin/bash
    set -e
    dnf update -y
    dnf install -y docker
    systemctl enable docker
    systemctl start docker
    usermod -aG docker ec2-user
    curl -SL https://github.com/docker/compose/releases/latest/download/docker-compose-linux-x86_64 -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
  EOF

  tags = merge(var.tags, {
    Name = "${var.project_name}-api-ec2"
  })
}
