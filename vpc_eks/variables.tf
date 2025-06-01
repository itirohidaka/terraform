# ---------------------------------------------------------------------------------------------------------------------
# ROOT MODULE VARIABLES
# These variables are used to configure the VPC and networking components
# ---------------------------------------------------------------------------------------------------------------------

variable "vpc_name" {
  description = "Name of the VPC. This will be used for tagging and identification."
  type        = string
  default     = "eks-vpc"  # Default name for the VPC
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC. This defines the IP address range for the entire VPC."
  type        = string
  default     = "10.0.0.0/16"  # Default CIDR block with 65,536 IP addresses
}

variable "azs" {
  description = "Availability zones to use. Resources will be distributed across these AZs for high availability."
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]  # Default to two AZs in us-east-1 region
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets. These subnets will have direct internet access."
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]  # Default public subnet CIDR blocks
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets. These subnets will access internet via NAT Gateway."
  type        = list(string)
  default     = ["10.0.3.0/24", "10.0.4.0/24"]  # Default private subnet CIDR blocks
}