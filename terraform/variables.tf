# Region for all resources. Policy target: approved EU regions only.
variable "aws_region" {
  # Explanation shown in Terraform and HCP (HashiCorp Cloud Platform).
  description = "AWS region for all resources. Sentinel restricts this to approved EU regions."
  # Value must be text.
  type = string
  # Value used if none is supplied (Stockholm).
  default = "eu-north-1"
}

# Machine size. Policy target: approved instance types.
variable "instance_type" {
  description = "EC2 instance type. Sentinel restricts this to an approved list."
  type        = string
  default     = "t3.micro"
}

# Allowed SSH source range. Policy target: no 0.0.0.0/0.
variable "ssh_allowed_cidr" {
  description = "CIDR range allowed to reach SSH (port 22). Sentinel rejects 0.0.0.0/0."
  type        = string
  # Documentation-only range (RFC 5737). Replace with a real admin range if you ever log in.
  default = "203.0.113.0/24"
}