# ---------------------------------------------------------------------------------------------------------------------
# EKS CLUSTER OUTPUTS
# These outputs provide important information about the created EKS cluster
# ---------------------------------------------------------------------------------------------------------------------

output "cluster_id" {
  description = "The name of the EKS cluster. Can be used to reference the cluster in other resources or commands."
  value       = aws_eks_cluster.this.id
}

output "cluster_endpoint" {
  description = "The endpoint for the EKS cluster API server. Used for kubectl and other tools to connect to the cluster."
  value       = aws_eks_cluster.this.endpoint
}

output "cluster_certificate_authority_data" {
  description = "Base64 encoded certificate data required to communicate with the cluster. Used for secure communication."
  value       = aws_eks_cluster.this.certificate_authority[0].data
}