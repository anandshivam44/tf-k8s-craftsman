# Create AWS EKS Node Group - Private
resource "aws_eks_node_group" "eks_ng_private" {
  cluster_name = aws_eks_cluster.eks_cluster.name

  node_group_name = "${local.name}-eks-ng-private"
  node_role_arn   = aws_iam_role.eks_nodegroup_role.arn
  subnet_ids      = module.vpc.private_subnets

  capacity_type = "ON_DEMAND"

  dynamic "launch_template" {
    for_each = var.use_packer_ami ? [1] : []
    content {
      id      = aws_launch_template.eks_nodes_x86_64.id
      version = aws_launch_template.eks_nodes_x86_64.latest_version
    }
  }

  ami_type       = var.use_packer_ami ? null : var.private_node_ami_type
  instance_types = var.use_packer_ami ? null : var.private_node_instance_types
  disk_size      = var.use_packer_ami ? null : var.private_node_disk_size

  dynamic "remote_access" {
    for_each = var.use_packer_ami ? [] : [1]
    content {
      ec2_ssh_key = var.ec2_ssh_key_name
      source_security_group_ids = [module.public_bastion_sg.security_group_id]
    }
  }



  scaling_config {
    desired_size = 2
    min_size     = 2
    max_size     = 3
  }

  # Desired max percentage of unavailable worker nodes during node group update.
  update_config {
    max_unavailable = 1
    #max_unavailable_percentage = 50    # ANY ONE TO USE
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role_policy_attachment.eks-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.eks-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.eks-AmazonEC2ContainerRegistryReadOnly,
    aws_iam_role_policy_attachment.eks-AmazonSSMManagedInstanceCore,
    kubernetes_config_map_v1.aws_auth,
    aws_key_pair.eks_key
  ]
  tags = {
    Name = "Private-Node-Group"
  }
}

