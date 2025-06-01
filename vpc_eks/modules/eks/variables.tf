# ---------------------------------------------------------------------------------------------------------------------
# EKS CLUSTER VARIABLES
# These variables define the configuration for the Amazon EKS cluster
# ---------------------------------------------------------------------------------------------------------------------

variable "cluster_name" {
  description = "Name of the EKS cluster. This name will be used for the cluster and related resources."
  type        = string
  default     = "my-eks-cluster"
}

variable "cluster_version" {
  description = "Kubernetes version to use for the EKS cluster. Must be a valid EKS-supported version."
  type        = string
  default     = "1.32"  # Latest stable version as of configuration time
}

variable "vpc_id" {
  description = "VPC ID where the EKS cluster will be created. The VPC must have appropriate subnets and routing."
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for the EKS cluster. Should include at least two subnets in different AZs."
  type        = list(string)
}