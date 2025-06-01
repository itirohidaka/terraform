# ---------------------------------------------------------------------------------------------------------------------
# IAM MODULE OUTPUTS
# These outputs provide information about the modified IAM role
# ---------------------------------------------------------------------------------------------------------------------

output "role_id" {
  description = "The ID of the modified IAM role. Can be used to reference the role in other resources."
  value       = data.aws_iam_role.target_role.id
}

output "role_arn" {
  description = "The ARN (Amazon Resource Name) of the modified IAM role. Used for cross-account or service access."
  value       = data.aws_iam_role.target_role.arn
}