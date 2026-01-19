########################################
# KMS Key for RDS Encryption
########################################

resource "aws_kms_key" "rds_key" {
  description             = "KMS key for Aurora RDS encryption"
  enable_key_rotation     = true
  deletion_window_in_days = 7

  tags = var.tags
}

resource "aws_kms_alias" "rds_key_alias" {
  name          = "alias/fintech-rds-key"
  target_key_id = aws_kms_key.rds_key.id
}

########################################
# DB Subnet Group (Imported)
########################################

resource "aws_db_subnet_group" "fintech" {
  name       = "fintech-db-subnets"
  subnet_ids = var.db_subnet_ids

  tags = var.tags
}

########################################
# RDS Security Group
########################################

resource "aws_security_group" "db_sg" {
  name        = "fintech-db-sg"
  description = "Managed by Terraform"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.tags
}

resource "aws_security_group_rule" "allow_ecs_to_db" {
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  security_group_id        = aws_security_group.db_sg.id
  source_security_group_id = var.ecs_sg_id
}

########################################
# Aurora PostgreSQL Cluster
########################################

resource "aws_rds_cluster" "aurora" {
  cluster_identifier      = "fintech-cluster"
  engine                  = "aurora-postgresql"
  engine_version          = "14.8"
  master_username         = "fintechadmin"
  master_password         = var.db_master_password
  db_subnet_group_name    = aws_db_subnet_group.fintech.name
  vpc_security_group_ids  = [aws_security_group.db_sg.id]
  storage_encrypted       = true
  kms_key_id              = aws_kms_key.rds_key.arn
  skip_final_snapshot     = false

  tags = var.tags
}


