# Firewall (security group) for the instance.
resource "aws_security_group" "sovereign_compute" {
  # Name shown in the AWS console.
  name = "sovereign-compute-sg"
  # Short explanation shown in AWS.
  description = "Restricted access for sovereign-compute instance"

  # Label shown in the AWS console.
  tags = {
    Name = "sovereign-compute-sg"
  }
}

# Inbound rule. Policy target: no SSH (Secure Shell) open to 0.0.0.0/0.
resource "aws_vpc_security_group_ingress_rule" "ssh" {
  # Which security group this rule belongs to.
  security_group_id = aws_security_group.sovereign_compute.id
  # Short explanation shown in AWS.
  description = "SSH from approved admin range"
  # Protocol: TCP (Transmission Control Protocol).
  ip_protocol = "tcp"
  # Port range start and end. Both 22 means only SSH.
  from_port = 22
  to_port   = 22
  # Allowed source IP range, from variables.tf.
  cidr_ipv4 = var.ssh_allowed_cidr
}

# Outbound rule: HTTPS only (updates, AWS APIs).
resource "aws_vpc_security_group_egress_rule" "https" {
  # Which security group this rule belongs to.
  security_group_id = aws_security_group.sovereign_compute.id
  # Short explanation shown in AWS.
  description = "HTTPS outbound"
  # Protocol: TCP.
  ip_protocol = "tcp"
  # Port 443 is HTTPS.
  from_port = 443
  to_port   = 443
  # Any destination address.
  cidr_ipv4 = "0.0.0.0/0"
}