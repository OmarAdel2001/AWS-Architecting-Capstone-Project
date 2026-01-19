# Random suffix so bucket name is globally unique
resource "random_id" "bucket" {
  byte_length = 4
}

# -----------------------------
# Main Data Lake Bucket
# -----------------------------
resource "aws_s3_bucket" "data_lake" {
  bucket = "fintech-data-lake-${random_id.bucket.hex}"

  tags = {
    Project     = "FinTech"
    Environment = "Production"
  }
}

# Enable versioning
resource "aws_s3_bucket_versioning" "data_lake" {
  bucket = aws_s3_bucket.data_lake.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Enable KMS encryption + bucket key
resource "aws_s3_bucket_server_side_encryption_configuration" "data_lake" {
  bucket = aws_s3_bucket.data_lake.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = var.kms_key_id
    }
    bucket_key_enabled = true
  }
}

# Block all public access
resource "aws_s3_bucket_public_access_block" "data_lake" {
  bucket = aws_s3_bucket.data_lake.id

  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}

# -----------------------------
# Logging Bucket
# -----------------------------
resource "aws_s3_bucket" "log_bucket" {
  bucket = "fintech-s3-logs-${random_id.bucket.hex}"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "log_bucket" {
  bucket = aws_s3_bucket.log_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Enable access logging
resource "aws_s3_bucket_logging" "data_lake" {
  bucket = aws_s3_bucket.data_lake.id

  target_bucket = aws_s3_bucket.log_bucket.id
  target_prefix = "access-logs/"
}

# -----------------------------
# “Folder” structure (prefixes)
# -----------------------------
resource "aws_s3_object" "folders" {
  for_each = toset([
    "raw/transactions/",
    "raw/logs/",
    "raw/events/",
    "processed/daily-reports/",
    "processed/aggregations/",
    "archive/compliance/",
    "analytics/ml-data/"
  ])

  bucket = aws_s3_bucket.data_lake.id
  key    = each.value
}

# -----------------------------
# Intelligent-Tiering
# -----------------------------
resource "aws_s3_bucket_intelligent_tiering_configuration" "data_lake" {
  bucket = aws_s3_bucket.data_lake.id
  name   = "EntireBucket"

  tiering {
    access_tier = "ARCHIVE_ACCESS"
    days        = 90
  }

  tiering {
    access_tier = "DEEP_ARCHIVE_ACCESS"
    days        = 180
  }
}

# -----------------------------
# Lifecycle rules
# -----------------------------
resource "aws_s3_bucket_lifecycle_configuration" "data_lake" {
  bucket = aws_s3_bucket.data_lake.id

  rule {
    id     = "ArchiveOldData"
    status = "Enabled"

    filter {
      prefix = "archive/"
    }

    transition {
      days          = 90
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = 180
      storage_class = "GLACIER"
    }

    transition {
      days          = 365
      storage_class = "DEEP_ARCHIVE"
    }
  }

  rule {
    id     = "DeleteOldVersions"
    status = "Enabled"

    noncurrent_version_expiration {
      noncurrent_days = 90
    }
  }
}

# -----------------------------
# Outputs (useful later)
# -----------------------------
output "data_lake_bucket_name" {
  value = aws_s3_bucket.data_lake.bucket
}

output "log_bucket_name" {
  value = aws_s3_bucket.log_bucket.bucket
}
