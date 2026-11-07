variable "aws_region" {
  description = "AWS region for all resources. Sentinel restricts this to approved EU regions."
  type        = string
  default     = "eu-north-1"
}

variable "instance_type" {
  description = "EC2 instance type. Sentinel restricts this to an approved list."
  type        = string
  default     = "t3.micro"
}

