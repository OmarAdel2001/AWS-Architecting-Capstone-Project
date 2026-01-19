

resource "aws_dynamodb_table" "sessions" {
  name         = "fintech-sessions"
  billing_mode = "PROVISIONED"

  hash_key  = "userId"
  range_key = "sessionId"

  attribute {
    name = "userId"
    type = "S"
  }

  attribute {
    name = "sessionId"
    type = "S"
  }

  read_capacity  = 5
  write_capacity = 5

  stream_enabled   = true
  stream_view_type = "NEW_AND_OLD_IMAGES"

  server_side_encryption {
    enabled     = true
    kms_key_arn = var.kms_key_id
  }

  tags = {
    Project     = "FinTech"
    Environment = "Production"
  }
}
