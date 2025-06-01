# ---------------------------------------------------------------------------------------------------------------------
# IAM MODULE
# This module configures IAM roles and policies for cross-role access
# ---------------------------------------------------------------------------------------------------------------------

# Look up the existing IAM role by name
data "aws_iam_role" "target_role" {
  name = var.role_name  # Use the role name provided as input
}

# Create an inline policy that allows the target role to be assumed by the source role
resource "aws_iam_role_policy" "assume_role_policy" {
  name   = "AssumeRolePolicy"  # Name of the inline policy
  role   = data.aws_iam_role.target_role.id  # Attach to the target role
  
  # Define the policy document using JSON
  policy = jsonencode({
    Version = "2012-10-17",  # Policy language version
    Statement = [
      {
        Action   = "sts:AssumeRole",  # Allow the AssumeRole action
        Effect   = "Allow",           # Allow the action (not deny)
        Resource = var.source_role_arn  # The role ARN that can be assumed
      }
    ]
  })
}