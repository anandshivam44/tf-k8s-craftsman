# Open SSH from Bastion SG to the EKS Cluster Security Group when using the Launch Template path
# This avoids specifying security_groups in the Launch Template and plays well with EKS-managed SGs.

resource "aws_security_group_rule" "allow_ssh_from_bastion_to_nodes" {
  count = var.use_packer_ami ? 1 : 0

  type                     = "ingress"
  description              = "Allow SSH from Bastion to EKS worker nodes (LT path)"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  security_group_id        = aws_eks_cluster.eks_cluster.vpc_config[0].cluster_security_group_id
  source_security_group_id = module.public_bastion_sg.security_group_id
}
