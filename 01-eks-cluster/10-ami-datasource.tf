# Get latest AMI ID for Amazon Linux2 OS
data "aws_ami" "eks_custom_al2023_x86_64" {
  most_recent = true
  owners      = ["self"]

  filter {
    name   = "name"
    values = ["al2023-eks-x86_64-1-33-*"]
  }

  filter {
    name   = "tag:Project"
    values = ["tf-k8s-craftsman"]
  }

  filter {
    name   = "tag:Architecture"
    values = ["x86_64"]
  }
}

data "aws_ami" "amzlinux2" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["al2023-ami-*-kernel-*-x86_64"]
  }
  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

}
