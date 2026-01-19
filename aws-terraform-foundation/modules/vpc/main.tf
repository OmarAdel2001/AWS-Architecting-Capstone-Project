variable "region" {
  type        = string
  description = "AWS region where the VPC will be created"
}

data "aws_availability_zones" "available" {
  state = "available"
}

# VPC
resource "aws_vpc" "prod" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "fintech-prod-vpc"
    Environment = "Production"
  }
}

# Public Subnets
resource "aws_subnet" "public_a" {
  vpc_id            = aws_vpc.prod.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "fintech-public-az-a"
  }
}

resource "aws_subnet" "public_b" {
  vpc_id            = aws_vpc.prod.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = data.aws_availability_zones.available.names[1]

  tags = {
    Name = "fintech-public-az-b"
  }
}

# Private App Subnets
resource "aws_subnet" "private_app_a" {
  vpc_id            = aws_vpc.prod.id
  cidr_block        = "10.0.11.0/24"
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "fintech-private-app-az-a"
  }
}

resource "aws_subnet" "private_app_b" {
  vpc_id            = aws_vpc.prod.id
  cidr_block        = "10.0.12.0/24"
  availability_zone = data.aws_availability_zones.available.names[1]

  tags = {
    Name = "fintech-private-app-az-b"
  }
}

# Database Subnets
resource "aws_subnet" "db_a" {
  vpc_id            = aws_vpc.prod.id
  cidr_block        = "10.0.21.0/24"
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "fintech-db-az-a"
  }
}

resource "aws_subnet" "db_b" {
  vpc_id            = aws_vpc.prod.id
  cidr_block        = "10.0.22.0/24"
  availability_zone = data.aws_availability_zones.available.names[1]

  tags = {
    Name = "fintech-db-az-b"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.prod.id

  tags = {
    Name = "fintech-igw"
  }
}

# NAT Gateway
resource "aws_eip" "nat" {
  domain = "vpc"
}

resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public_a.id

  tags = {
    Name = "fintech-nat-gw"
  }
}





