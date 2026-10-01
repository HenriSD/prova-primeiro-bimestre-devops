resource "aws_db_subnet_group" "main" {
  name       = "${var.project_name}-db-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = merge(var.tags, {
    Name = "${var.project_name}-db-subnet-group"
  })
}

resource "aws_db_instance" "postgres" {
  identifier     = "${var.project_name}-db"
  engine         = "postgres"
  engine_version = "16"
  instance_class = var.instance_class

  allocated_storage = 20
  storage_type       = "gp3"
  storage_encrypted  = true

  db_name  = var.db_name
  username = var.db_username
  password = var.db_password

  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [var.security_group_id]
  publicly_accessible    = false

  multi_az            = false
  skip_final_snapshot = true
  deletion_protection = false

  backup_retention_period = 0 # Lab: sem necessidade de backup automatico (economiza recursos)

  tags = merge(var.tags, {
    Name = "${var.project_name}-rds"
  })
}
