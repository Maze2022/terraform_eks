# ---------vpc/main.tf

data "aws_availability_zones" "available" {}

resource "random_integer" "random" {
  min = 1
  max = 100
}

resource "aws_vpc" "eks_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "eks_vpc-${random_integer.random.id}"
  }
}

#Public subnets
resource "aws_subnet" "eks_public_subnets" {
  count                   = var.public_sn_count
  vpc_id                  = aws_vpc.eks_vpc.id
  cidr_block              = var.public_cidrs[count.index]
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "eks_public_subnet_${count.index + 1}"
  }
}

#Route Table for Public Subnets
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.eks_vpc.id

  tags = {
    Name = "public_rt"
  }
}

#Associate public subnets with routing table
resource "aws_route_table_association" "Public_assoc" {
  count          = var.public_sn_count
  subnet_ids      = aws_subnet.eks_public_subnets[*].id[count.index]
  route_table_id = aws_route_table.public_rt.id
}

#Internet gateway
resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.eks_vpc.id

  tags = {
    Name = "my_igw"
  }
}

resource "aws_default_route_table" "default_public_rt" {
  default_route_table_id = aws_vpc.eks_vpc.default_route_table_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }
}

# 
