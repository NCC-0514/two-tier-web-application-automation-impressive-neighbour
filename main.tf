# Step 1 - Define the provider
provider "aws" {
  region = "us-east-1"
}

# Data source for availability zones in us-east-1
data "aws_availability_zones" "available" {
  state = "available"
}

# Local variables
locals {
  default_tags = merge(
    var.default_tags,
    { "Env" = var.env }
  )
  name_prefix = "${var.prefix}-${var.env}"
}

# Create a new VPC 
resource "aws_vpc" "main" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"
  tags = merge(
    local.default_tags, {
      Name = "${local.name_prefix}-vpc"
    }
  )
}

# Add provisioning of the public subnet in the default VPC
resource "aws_subnet" "public_subnet" {
  count             = length(var.public_subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.public_subnet_cidrs[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags = merge(
    local.default_tags, {
      Name = "${local.name_prefix}-public-subnet-${count.index}"
    }
  )
}

# Add provisioning of the private subnet in the default VPC
resource "aws_subnet" "private_subnet" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags = merge(
    local.default_tags, {
      Name = "${local.name_prefix}-private-subnet-${count.index}"
    }
  )
}

# Create Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = merge(local.default_tags,
    {
      "Name" = "${local.name_prefix}-igw"
    }
  )
}

# Route table to route add default gateway pointing to Internet Gateway (IGW)
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "${local.name_prefix}-route-public-route_table"
  }
}

# Associate subnets with the custom route table
resource "aws_route_table_association" "public_route_table_association" {
  count          = length(aws_subnet.public_subnet[*].id)
  route_table_id = aws_route_table.public_route_table.id
  subnet_id      = aws_subnet.public_subnet[count.index].id
}



# my changes
