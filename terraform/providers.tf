provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Organisation = "L00205287"
      Project      = "digital-sovereignty"
      ManagedBy    = "terraform"
    }
  }
}