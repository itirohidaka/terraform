# ---------------------------------------------------------------------------------------------------------------------
# TERRAFORM MAIN CONFIGURATION
# This file defines the main infrastructure components by calling the appropriate modules
# ---------------------------------------------------------------------------------------------------------------------

data "aws_caller_identity" "current" {}

# VPC Module - Creates a Virtual Private Cloud with public and private subnets
module "vpc" {
  source = "./modules/vpc"  # Path to the local VPC module
  
  # Pass VPC configuration parameters from root variables
  vpc_name = var.vpc_name  # Name of the VPC
  vpc_cidr = var.vpc_cidr  # CIDR block for the VPC
  
  # Network configuration
  azs                 = var.azs                 # Availability zones to use
  public_subnet_cidrs = var.public_subnet_cidrs # CIDR blocks for public subnets
  private_subnet_cidrs = var.private_subnet_cidrs # CIDR blocks for private subnets
}

# IAM Module - Configures IAM roles and policies
module "iam" {
  source = "./modules/iam"  # Path to the local IAM module
  
  # IAM role configuration
  role_name      = "WSParticipantRole"  # The role to modify
  source_role_arn = data.aws_caller_identity.current.arn  # Dynamically use the current caller's ARN
}

# EKS Module - Creates an Amazon EKS cluster
module "eks" {
  source = "./modules/eks"  # Path to the local EKS module
  
  # EKS cluster configuration
  cluster_name    = "workshop-eks-cluster"  # Name of the EKS cluster
  cluster_version = "1.32"                  # Kubernetes version for the cluster
  vpc_id          = module.vpc.vpc_id       # VPC where the cluster will be created
  subnet_ids      = module.vpc.private_subnet_ids  # Subnets where the cluster will be deployed

}