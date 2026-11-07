# Configure the AWS provider (the plugin that talks to AWS).
provider "aws" {
  # Region comes from variables.tf.
  region = var.aws_region

  # Tags added automatically to every resource that supports tags.
  default_tags {
    tags = {
      Organisation = "L00205287"
      Project      = "digital-sovereignty"
      # Records that Terraform created the resource.
      ManagedBy = "terraform"
    }
  }
}