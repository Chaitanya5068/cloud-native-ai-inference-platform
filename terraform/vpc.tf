# VPC Resource
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.project_name}-vpc"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-igw"
  }
}

# Elastic IP for NAT Gateway
resource "aws_eip" "nat" {
  count             = var.enable_nat_gateway ? 1 : 0
  domain            = "vpc"
  depends_on        = [aws_internet_gateway.main]

  tags = {
    Name = "${var.project_name}-nat-eip"
  }
}

# NAT Gateway for private subnet to reach internet
resource "aws_nat_gateway" "main" {
  count             = var.enable_nat_gateway ? 1 : 0
  allocation_id     = aws_eip.nat[0].id
  subnet_id         = aws_subnet.public.id
  depends_on        = [aws_internet_gateway.main]

  tags = {
    Name = "${var.project_name}-nat-gateway"
  }
}
