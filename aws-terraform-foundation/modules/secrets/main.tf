# -----------------------------
# Generate passwords
# -----------------------------

# Redis password (you already had this)
resource "random_password" "redis" {
  length  = 32
  special = true
}

# 🔹 ADD THIS → RDS Master Password (YOU WERE MISSING THIS)
resource "random_password" "db_master" {
  length           = 16
  special          = true
  override_special = "!@#%^&*()-_=+[]{}"
}

# -----------------------------
# Secrets Manager - API Keys
# -----------------------------
resource "aws_secretsmanager_secret" "api_keys" {
  name        = "fintech/api-keys"
  description = "API keys for external services"
  kms_key_id  = var.kms_key_id
}

resource "aws_secretsmanager_secret_version" "api_keys_value" {
  secret_id = aws_secretsmanager_secret.api_keys.id

  secret_string = jsonencode({
    stripe_api_key   = "sk_live_placeholder"
    sendgrid_api_key = "SG.placeholder"
  })
}

# -----------------------------
# Secrets Manager - Redis Auth
# -----------------------------
resource "aws_secretsmanager_secret" "redis_auth" {
  name        = "fintech/redis-auth"
  description = "ElastiCache Redis authentication token"
  kms_key_id  = var.kms_key_id
}

resource "aws_secretsmanager_secret_version" "redis_auth_value" {
  secret_id = aws_secretsmanager_secret.redis_auth.id

  # Store Redis password (encoded)
  secret_string = base64encode(random_password.redis.result)
}

# -----------------------------
# IAM Policy to allow ECS tasks to read secrets
# -----------------------------
resource "aws_iam_policy" "ecs_secrets_policy" {
  name = "ECS-SecretsManager-Access"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Resource = "arn:aws:secretsmanager:us-east-1:${var.account_id}:secret:fintech/*"
      }
    ]
  })
}

# -----------------------------
# Outputs (VERY IMPORTANT)
# -----------------------------

output "api_keys_secret_arn" {
  value = aws_secretsmanager_secret.api_keys.arn
}

output "redis_auth_secret_arn" {
  value = aws_secretsmanager_secret.redis_auth.arn
}

# ✅ NOW THIS WORKS (because db_master exists)
output "rds_master_password" {
  value     = random_password.db_master.result
  sensitive = true
}

