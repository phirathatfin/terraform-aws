terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "ap-southeast-1"
}

# Create a VPC
resource "aws_vpc" "terraform_vpc" {
  cidr_block = "124.16.0.0/16"

  tags = {
    Name = "terraform_vpc"
  }
}

# Create a public subnet with 3 availability zones
resource "aws_subnet" "terraform_public_subnet" {
  count             = 3
  vpc_id            = aws_vpc.terraform_vpc.id
  cidr_block        = "124.16.${count.index * 16}.0/20" 
  availability_zone = "ap-southeast-1${element(["a", "b", "c"], count.index)}" 

  tags = {
    Name = "terraform-public-subnet-${count.index}"
  }
}

# Create a private subnet with 3 availability zones
resource "aws_subnet" "terraform_private_subnet" {
  count             = 3
  vpc_id            = aws_vpc.terraform_vpc.id
  cidr_block        = "124.16.${count.index * 16 + 128}.0/20" // will be 124.16.128.0/20, 124.16.144.0/20
  availability_zone = "ap-southeast-1${element(["a", "b", "c"], count.index)}" 

  tags = {
    Name = "terraform-private-subnet-${count.index}"
  }
}

# Create a public route table and associate it with the public subnets
resource "aws_route_table" "terraform_public_route_table" {
  vpc_id = aws_vpc.terraform_vpc.id

  tags = {
    Name = "terraform-public-route-table"
  }
}

resource "aws_route_table_association" "terraform_public_subnet_association" {
  count          = 3
  subnet_id      = aws_subnet.terraform_public_subnet[count.index].id
  route_table_id = aws_route_table.terraform_public_route_table.id
}

# Create private route tables for each private subnet and associate it with the private subnets
resource "aws_route_table" "terraform_private_route_table" {
  count = 3
  vpc_id = aws_vpc.terraform_vpc.id

  tags = {
    Name = "terraform-private-route-table-${count.index}"
  }
}

resource "aws_route_table_association" "terraform_private_subnet_association" {
  count          = 3
  subnet_id      = aws_subnet.terraform_private_subnet[count.index].id
  route_table_id = aws_route_table.terraform_private_route_table[count.index].id
}

# Create an internet gateway
resource "aws_internet_gateway" "terraform_internet_gateway" {
  vpc_id = aws_vpc.terraform_vpc.id

  tags = {
    Name = "terraform-internet-gateway"
  }
}

# Create a route to the internet gateway
resource "aws_route" "terraform_internet_gateway_route" {
  route_table_id            = aws_route_table.terraform_public_route_table.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id                = aws_internet_gateway.terraform_internet_gateway.id
}
