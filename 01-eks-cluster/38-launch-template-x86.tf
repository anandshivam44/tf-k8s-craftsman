resource "aws_launch_template" "eks_nodes_x86_64" {
  name_prefix   = "eks-nodes-x86_64-"
  image_id      = data.aws_ami.eks_custom_al2023_x86_64.id
  instance_type = "t3.medium"

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size = 20
      volume_type = "gp3"
    }
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "eks-worker-node-x86_64"
    }
  }

  user_data = base64encode(<<-EOF
#!/bin/bash
set -o xtrace
/etc/eks/bootstrap.sh ${aws_eks_cluster.eks_cluster.name}
EOF
)

  lifecycle {
    create_before_destroy = true
  }
}
