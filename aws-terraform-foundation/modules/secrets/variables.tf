variable "account_id" {
  type        = string
  description = "AWS Account ID for naming/permissions"
}

variable "kms_key_id" {
  type        = string
  description = "KMS key used for Secrets Manager encryption"
}
