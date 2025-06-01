# ---------------------------------------------------------------------------------------------------------------------
# VPC MODULE OUTPUTS
# These outputs provide important information about the created VPC resources
# ---------------------------------------------------------------------------------------------------------------------

output "vpc_id" {
  description = "The ID of the VPC. Used to reference the VPC in other resources and modules."
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "List of public subnet IDs. These subnets have direct internet access via Internet Gateway."
  value       = aws_subnet.public[*].id  # Returns a list of all public subnet IDs
}

output "private_subnet_ids" {
  description = "List of private subnet IDs. These subnets access internet via NAT Gateway."
  value       = aws_subnet.private[*].id  # Returns a list of all private subnet IDs
}

output "nat_gateway_id" {
  description = "ID of the NAT Gateway. Used for routing traffic from private subnets to the internet."
  value       = aws_nat_gateway.nat_gw.id
}

output "internet_gateway_id" {
  description = "ID of the Internet Gateway. Provides direct internet access for public subnets."
  value       = aws_internet_gateway.igw.id
}