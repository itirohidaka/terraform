# ---------------------------------------------------------------------------------------------------------------------
# ROOT MODULE OUTPUTS
# These outputs expose important information about the created resources
# ---------------------------------------------------------------------------------------------------------------------

output "vpc_id" {
  description = "The ID of the created VPC. Can be used to reference the VPC in other resources."
  value = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "List of public subnet IDs. These subnets have direct internet access."
  value = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "List of private subnet IDs. These subnets access internet via NAT Gateway."
  value = module.vpc.private_subnet_ids
}

output "modified_role_arn" {
  description = "The ARN of the modified IAM role with assume role permissions."
  value = module.iam.role_arn
}

output "eks_cluster_id" {
  description = "The ID/name of the EKS cluster. Used for referencing the cluster in kubectl commands."
  value = module.eks.cluster_id
}

output "eks_cluster_endpoint" {
  description = "The endpoint URL for the EKS cluster API server. Used for kubectl configuration."
  value = module.eks.cluster_endpoint
}