terraform {
  # Only this exact Terraform version may run. Supports supply chain control.
  required_version = "= 1.16.6"

  required_providers {
    aws = {
      # Provider source: HashiCorp's official registry namespace.
      source = "hashicorp/aws"
      # Any 6.x version, but not 7.0 or later.
      version = "~> 6.0"
    }
  }
}