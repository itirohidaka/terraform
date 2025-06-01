# ---------------------------------------------------------------------------------------------------------------------
# IAM MODULE VARIABLES
# These variables define the configuration for IAM roles and policies
# ---------------------------------------------------------------------------------------------------------------------

variable "role_name" {
  description = "Name of the IAM role to modify. This role will receive the assume role policy."
  type        = string
  default     = "WSParticipantRole"  # Default role name
}

variable "source_role_arn" {
  description = "ARN of the role that will be allowed to assume the target role. This defines the trust relationship."
  type        = string
}