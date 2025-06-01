# ---------------------------------------------------------------------------------------------------------------------
# AMAZON EKS CLUSTER
# This module creates an Amazon EKS cluster with Auto Mode enabled and configures access for specific roles
# ---------------------------------------------------------------------------------------------------------------------

# Create the EKS cluster with specified configuration
resource "aws_eks_cluster" "this" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks_cluster.arn  # Reference to the IAM role created below
  version  = var.cluster_version         # Kubernetes version from variables
  bootstrap_self_managed_addons = false

  # Configure networking for the EKS cluster
  vpc_config {
    subnet_ids = var.subnet_ids  # Subnets where cluster resources will be provisioned
  }

  # Configure authentication and access settings
  access_config {
    authentication_mode = "API_AND_CONFIG_MAP"  # Use both API server and ConfigMap for authentication
    bootstrap_cluster_creator_admin_permissions = true  # Grant admin permissions to the creator
  
  }

  compute_config {
    enabled       = true
  }

  kubernetes_network_config {
    elastic_load_balancing {
      enabled = true
    }
  }

  storage_config {
    block_storage {
      enabled = true
    }
  }

}

resource "aws_iam_role" "eks_cluster" {
  name = "${var.cluster_name}-cluster-role"  # Name based on cluster name

  # Trust policy allowing EKS service to assume this role
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"  # AWS managed policy for EKS
  role       = aws_iam_role.eks_cluster.name
}

# Create an IAM role mapping for the aws-auth ConfigMap
# This is needed for backward compatibility with older EKS authentication
# and to support wildcard patterns for vscode-server-* roles
resource "null_resource" "update_aws_auth" {
  depends_on = [aws_eks_cluster.this]  # Ensure cluster exists first

  # Use local-exec to apply the ConfigMap using kubectl
  provisioner "local-exec" {
    command = <<-EOT
      aws eks update-kubeconfig --name ${aws_eks_cluster.this.name} --region us-east-1
      cat <<EOF | kubectl apply -f -
      apiVersion: v1
      kind: ConfigMap
      metadata:
        name: aws-auth
        namespace: kube-system
      data:
        mapRoles: |
          - rolearn: arn:aws:iam::732094707402:role/WSParticipantRole
            username: WSParticipantRole
            groups:
              - system:masters
          - rolearn: arn:aws:iam::732094707402:role/vscode-server-*
            username: vscode-server
            groups:
              - system:masters
      EOF
    EOT
  }
}
