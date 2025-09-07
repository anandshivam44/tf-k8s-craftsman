# Security Group to allow SSH from Bastion to EKS worker nodes (used when Launch Template is enabled)
# This SG is intended to be attached to the worker node ENIs via the Launch Template.

resource "aws_security_group" "eks_nodes_ssh" {
  # Disabled by default; we instead open SSH on the EKS Cluster SG to avoid overriding node SGs via Launch Template
  count       = 0
  name        = "${local.name}-eks-nodes-ssh"
  description = "Allow SSH from Bastion to EKS worker nodes"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "SSH from Bastion"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    security_groups = [
      module.public_bastion_sg.security_group_id
    ]
  }

  egress {
    description = "Allow all egress"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, {
    Name = "${local.name}-eks-nodes-ssh"
  })
}
