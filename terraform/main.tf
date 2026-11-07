# Look up the Amazon Linux 2023 AMI (Amazon Machine Image) ID from AWS's public SSM (Systems Manager) parameter.
data "aws_ssm_parameter" "al2023" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

# EC2 (Elastic Compute Cloud) instance: the virtual machine the policies check.
resource "aws_instance" "sovereign_compute" {
  # Disk image to start from.
  ami = data.aws_ssm_parameter.al2023.value

  # Machine size. Policy target: approved instance types.
  instance_type = var.instance_type

  # Firewall from network.tf. Policy target: SSH rule.
  vpc_security_group_ids = [aws_security_group.sovereign_compute.id]

  # Main disk. Policy target: encrypted EBS (Elastic Block Store).
  root_block_device {
    # Encrypt the disk at rest.
    encrypted = true
    # General-purpose SSD (solid-state drive) type.
    volume_type = "gp3"
    # Size in GiB (gibibytes).
    volume_size = 8
  }

  # Instance metadata service settings. Policy target: mandatory IMDSv2 (Instance Metadata Service version 2).
  metadata_options {
    # Require a session token. "optional" would also allow IMDSv1.
    http_tokens = "required"
    # Keep the metadata service switched on.
    http_endpoint = "enabled"
  }

  # Name shown in the AWS console.
  tags = {
    Name = "sovereign-compute"
  }
}