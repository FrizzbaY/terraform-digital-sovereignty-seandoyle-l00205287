variable "aws_region" {
  description = "AWS region for all resources. Sentinel restricts this to approved EU regions."
  type        = string
  default     = "eu-north-1"
}