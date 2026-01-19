variable "subnet_ids" {
  type        = list(string)
  description = "Subnet IDs for ElastiCache subnet group"
}

variable "tags" {
  type        = map(string)
  description = "Tags for ElastiCache resources"
  default     = {}
}
