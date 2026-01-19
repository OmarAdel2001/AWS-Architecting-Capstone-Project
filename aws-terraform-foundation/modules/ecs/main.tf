variable "vpc_id" {
  type        = string
  description = "VPC where ECS will be deployed"
}

variable "private_subnet_a" {
  type = string
}

variable "private_subnet_b" {
  type = string
}

variable "public_subnet_a" {
  type = string
}

variable "public_subnet_b" {
  type = string
}

# -----------------------------
# ECS Cluster
# -----------------------------
resource "aws_ecs_cluster" "fintech" {
  name = "fintech-cluster"

  tags = {
    Environment = "Production"
    Project     = "FinTech"
  }
}

# -----------------------------
# Task Execution Role
# -----------------------------
resource "aws_iam_role" "ecs_execution" {
  name = "ecsTaskExecutionRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_exec_attach" {
  role       = aws_iam_role.ecs_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# -----------------------------
# Security Group for ECS Tasks
# -----------------------------
resource "aws_security_group" "ecs_sg" {
  name        = "fintech-ecs-sg"
  description = "Security group for ECS tasks"
  vpc_id      = var.vpc_id
}

# -----------------------------
# (Optional for now) Outputs needed by other modules
# -----------------------------
output "ecs_sg_id" {
  value = aws_security_group.ecs_sg.id
}
