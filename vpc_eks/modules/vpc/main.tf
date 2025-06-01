# ---------------------------------------------------------------------------------------------------------------------
# VPC MODULE
# This module creates a complete VPC infrastructure with public and private subnets
# ---------------------------------------------------------------------------------------------------------------------

# Create VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr  # IP address range for the VPC
  enable_dns_hostnames = true          # Enable DNS hostnames for EC2 instances
  enable_dns_support   = true          # Enable DNS resolution in the VPC

  tags = {
    Name = var.vpc_name  # Tag the VPC with the provided name
  }
}

# Create Internet Gateway for public internet access
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id  # Attach to the VPC created above

  tags = {
    Name = "${var.vpc_name}-igw"  # Tag with VPC name + -igw suffix
  }
}

# Create public subnets - these will have direct internet access
resource "aws_subnet" "public" {
  count                   = length(var.public_subnet_cidrs)  # Create a subnet for each CIDR in the list
  vpc_id                  = aws_vpc.main.id                  # Attach to the VPC created above
  cidr_block              = var.public_subnet_cidrs[count.index]  # Use CIDR from the list
  availability_zone       = var.azs[count.index]             # Use AZ from the list
  map_public_ip_on_launch = true                             # Auto-assign public IPs to instances

  tags = {
    Name = "${var.vpc_name}-public-${count.index + 1}"  # Tag with VPC name + -public-N suffix
  }
}

# Create private subnets - these will access internet via NAT Gateway
resource "aws_subnet" "private" {
  count             = length(var.private_subnet_cidrs)  # Create a subnet for each CIDR in the list
  vpc_id            = aws_vpc.main.id                   # Attach to the VPC created above
  cidr_block        = var.private_subnet_cidrs[count.index]  # Use CIDR from the list
  availability_zone = var.azs[count.index]              # Use AZ from the list

  tags = {
    Name = "${var.vpc_name}-private-${count.index + 1}"  # Tag with VPC name + -private-N suffix
  }
}

# Create Elastic IP for NAT Gateway
resource "aws_eip" "nat" {
  domain = "vpc"  # Allocate EIP in the VPC domain

  tags = {
    Name = "${var.vpc_name}-nat-eip"  # Tag with VPC name + -nat-eip suffix
  }
}

# Create NAT Gateway for private subnet internet access
resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat.id         # Use the Elastic IP created above
  subnet_id     = aws_subnet.public[0].id  # Place in the first public subnet

  tags = {
    Name = "${var.vpc_name}-nat-gw"  # Tag with VPC name + -nat-gw suffix
  }

  # Ensure the Internet Gateway exists before creating the NAT Gateway
  depends_on = [aws_internet_gateway.igw]
}

# Create route table for public subnets
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id  # Attach to the VPC created above

  # Add a route to the internet via the Internet Gateway
  route {
    cidr_block = "0.0.0.0/0"             # All traffic
    gateway_id = aws_internet_gateway.igw.id  # Route through the Internet Gateway
  }

  tags = {
    Name = "${var.vpc_name}-public-rt"  # Tag with VPC name + -public-rt suffix
  }
}

# Create route table for private subnets
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id  # Attach to the VPC created above

  # Add a route to the internet via the NAT Gateway
  route {
    cidr_block     = "0.0.0.0/0"          # All traffic
    nat_gateway_id = aws_nat_gateway.nat_gw.id  # Route through the NAT Gateway
  }

  tags = {
    Name = "${var.vpc_name}-private-rt"  # Tag with VPC name + -private-rt suffix
  }
}

# Associate public subnets with public route table
resource "aws_route_table_association" "public" {
  count          = length(var.public_subnet_cidrs)  # Create an association for each public subnet
  subnet_id      = aws_subnet.public[count.index].id  # Associate with the public subnet
  route_table_id = aws_route_table.public.id        # Associate with the public route table
}

# Associate private subnets with private route table
resource "aws_route_table_association" "private" {
  count          = length(var.private_subnet_cidrs)  # Create an association for each private subnet
  subnet_id      = aws_subnet.private[count.index].id  # Associate with the private subnet
  route_table_id = aws_route_table.private.id        # Associate with the private route table
}