variable "vpc_id" {
  type        = string
  description = "VPC where ElastiCache will be deployed"
}

variable "db_subnet_a" {
  type = string
}

variable "db_subnet_b" {
  type = string
}

variable "ecs_sg_id" {
  type        = string
  description = "ECS tasks security group (allowed to access Redis)"
}

# -----------------------------
# Redis Subnet Group
# -----------------------------
resource "aws_elasticache_subnet_group" "redis_subnets" {
  name       = "fintech-redis-subnets"
  subnet_ids = var.subnet_ids

  lifecycle {
    ignore_changes = [subnet_ids]
  }

  tags = var.tags
}

# -----------------------------
# Redis Security Group  (FIXED HERE)
# -----------------------------
resource "aws_security_group" "redis_sg" {
  name        = "fintech-redis-sg"
  description = "Security group for ElastiCache Redis"
  vpc_id      = var.vpc_id
}

# Allow ECS tasks to access Redis (port 6379)
resource "aws_security_group_rule" "allow_ecs_to_redis" {
  type                     = "ingress"
  from_port                = 6379
  to_port                  = 6379
  protocol                 = "tcp"
  security_group_id        = aws_security_group.redis_sg.id
  source_security_group_id = var.ecs_sg_id
}

# -----------------------------
# Random Redis Auth Token
# -----------------------------
resource "random_password" "redis_auth" {
  length  = 32
  lower   = true
  upper   = true
  numeric = true
  special = false   # IMPORTANT FIX
}


# -----------------------------
# ElastiCache Redis (Multi-AZ)
# -----------------------------
resource "aws_elasticache_replication_group" "redis" {
  replication_group_id       = "fintech-redis-cluster"
  description                = "FinTech Redis cluster for caching"
  engine                     = "redis"
  engine_version             = "7.0"
  node_type                  = "cache.r6g.large"
  num_cache_clusters         = 2

  subnet_group_name          = aws_elasticache_subnet_group.redis_subnets.name
  security_group_ids         = [aws_security_group.redis_sg.id]

  at_rest_encryption_enabled = true
  transit_encryption_enabled = true
  auth_token                 = random_password.redis_auth.result

  automatic_failover_enabled = true
  multi_az_enabled           = true
  snapshot_retention_limit   = 7

  tags = {
    Project     = "FinTech"
    Environment = "Production"
  }
}

# -----------------------------
# Outputs (useful later)
# -----------------------------
output "redis_endpoint" {
  value = aws_elasticache_replication_group.redis.primary_endpoint_address
}

output "redis_auth_secret" {
  value = random_password.redis_auth.result
}
