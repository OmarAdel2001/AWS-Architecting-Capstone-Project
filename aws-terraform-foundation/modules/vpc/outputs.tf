output "vpc_id" {
  value = aws_vpc.prod.id
}

output "public_subnet_a" {
  value = aws_subnet.public_a.id
}

output "public_subnet_b" {
  value = aws_subnet.public_b.id
}

output "private_subnet_a" {
  value = aws_subnet.private_app_a.id
}

output "private_subnet_b" {
  value = aws_subnet.private_app_b.id
}

output "db_subnet_a" {
  value = aws_subnet.db_a.id
}

output "db_subnet_b" {
  value = aws_subnet.db_b.id
}
