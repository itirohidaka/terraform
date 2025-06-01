# ---------------------------------------------------------------------------------------------------------------------
# TERRAFORM PROVIDER CONFIGURATION
# Defines the providers that Terraform will use to interact with cloud services
# ---------------------------------------------------------------------------------------------------------------------

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.99.1"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}