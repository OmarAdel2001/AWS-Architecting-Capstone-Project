variable "vpc_id" {
  type = string
}

variable "db_subnet_ids" {
  type        = list(string)
  description = "Subnet IDs for RDS DB subnet group"
}

variable "ecs_sg_id" {
  type = string
}

variable "db_master_password" {
  type      = string
  sensitive = true
}

variable "tags" {
  type = map(string)
}
