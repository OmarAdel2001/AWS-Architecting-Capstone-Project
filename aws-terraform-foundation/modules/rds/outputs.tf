########################################
# OUTPUTS (IMPORTANT)
########################################

output "kms_key_id" {
  value = aws_kms_key.rds_key.arn
}

output "db_security_group_id" {
  value = aws_security_group.db_sg.id
}