
terraform {
 required_providers {
   aws = {
     source  = "hashicorp/aws"
     version = "~> 4.19.0"
   }
 }
}

provider "aws" {
  # Configuration options
  region  = "us-east-1"
  profile = "default"
}

resource "aws_vpc" "coin98" {
  cidr_block = "172.20.0.0/16"

  tags = {
    Name        = "coin98-vpc"
    Environment = "dev"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.coin98.id

  tags = {
    Name        = "coin98-igw"
    Environment = "dev"
  }
}

resource "aws_subnet" "public_sub_01" {
  vpc_id            = aws_vpc.coin98.id
  cidr_block        = "172.20.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name        = "coin98-public-sub-01"
    Environment = "dev"
    Tier        = "public"
  }
}

resource "aws_subnet" "public_sub_02" {
  vpc_id            = aws_vpc.coin98.id
  cidr_block        = "172.20.2.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name        = "coin98-public-sub-02"
    Environment = "dev"
    Tier        = "public"
  }
}

resource "aws_subnet" "private_sub_01" {
  vpc_id            = aws_vpc.coin98.id
  cidr_block        = "172.20.3.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name        = "coin98-private-sub-03"
    Environment = "dev"
    Tier        = "private"
  }
}

resource "aws_subnet" "private_sub_02" {
  vpc_id            = aws_vpc.coin98.id
  cidr_block        = "172.20.4.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name        = "coin98-private-sub-04"
    Environment = "dev"
    Tier        = "private"
  }
}

resource "aws_eip" "nat_gateway" {
  tags = {
    Name = "EIP"
  }
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_gateway.id
  subnet_id     = aws_subnet.public_sub_01.id

  tags = {
    Name = "NAT gateway"
    Environment = "dev"
  }
}

resource "aws_route_table" "public_rtb" {
  vpc_id = aws_vpc.coin98.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "Coin98 route table public"
    Environment = "dev"
  }
}

resource "aws_route_table_association" "public_sub_01" {
  subnet_id      = aws_subnet.public_sub_01.id
  route_table_id = aws_route_table.public_rtb.id
}

resource "aws_route_table_association" "public_sub_02" {
  subnet_id      = aws_subnet.public_sub_02.id
  route_table_id = aws_route_table.public_rtb.id
}

resource "aws_route_table" "private_rtb" {
  vpc_id = aws_vpc.coin98.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat.id
  }

  tags = {
    Name = "Coin98 route table private"
    Environment = "dev"
  }
}

resource "aws_route_table_association" "private_sub_01" {
  subnet_id      = aws_subnet.private_sub_01.id
  route_table_id = aws_route_table.private_rtb.id
}

resource "aws_route_table_association" "private_sub_02" {
  subnet_id      = aws_subnet.private_sub_02.id
  route_table_id = aws_route_table.private_rtb.id
}
