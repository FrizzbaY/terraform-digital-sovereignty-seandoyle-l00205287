# Look up the current Amazon Linux 2023 AMI (Amazon Machine Image) ID
# from AWS's public SSM (Systems Manager) parameter, so no region-specific
# AMI ID is hardcoded.
data "aws_ssm_parameter" "al2023" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

resource "aws_instance" "sovereign_compute" {
  ami           = data.aws_ssm_parameter.al2023.value
  instance_type = var.instance_type

  # Policy target: encrypted EBS (Elastic Block Store) root volume
  root_block_device {
    encrypted   = true
    volume_type = "gp3"
    volume_size = 8
  }

  # Policy target: mandatory IMDSv2
  metadata_options {
    http_tokens   = "required"
    http_endpoint = "enabled"
  }

  tags = {
    Name = "sovereign-compute"
  }
}