resource "aws_vpc" "this_vpc" {
  cidr_block = var.vpc_cidr
  enable_dns_support = true
  enable_dns_hostnames = true
}

resource "aws_subnet" "public_subnet" {
  vpc_id = aws_vpc.this_vpc.id
  cidr_block = var.public_subnet_cidr
  map_public_ip_on_launch = true
  availability_zone = var.az

  tags = {
    "Name" = "Public-Subnet"
  }
}

resource "aws_subnet" "private_subnet" {
  vpc_id = aws_vpc.this_vpc.id
  cidr_block = var.private_subnet_cidr
  availability_zone = var.az
  
    tags = {
    "Name" = "Private-Subnet"
  }
}

resource "aws_internet_gateway" "aws_igw" {
  vpc_id = aws_vpc.this_vpc.id
  tags = {
    "Name" = "Internet-Gateway" 
  }
}

resource "aws_route_table" "public_table" {
  vpc_id = aws_vpc.this_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.aws_igw.id
  }
  
  tags = {
    "Name" = "Public-Route-Table" 
  }
}

resource "aws_route_table_association" "public_table_association" {
  subnet_id = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_table.id
}

resource "aws_route_table" "private_table" {
  vpc_id = aws_vpc.this_vpc.id

  tags = {
    "Name" = "Private-Route-Table" 
  }
}

resource "aws_route_table_association" "private_table_association" {
  subnet_id = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.private_table.id
}

resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name = "nat-eip"
  }
}

resource "aws_nat_gateway" "aws_nat" {
  allocation_id = aws_eip.nat.id
  subnet_id = aws_subnet.public_subnet.id

  tags = {
    "Name" = "Nat-Gateway" 
  }

  depends_on = [ aws_internet_gateway.aws_igw ]
}

resource "aws_route" "private_nat" {
  route_table_id = aws_route_table.private_table.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.aws_nat.id
}
