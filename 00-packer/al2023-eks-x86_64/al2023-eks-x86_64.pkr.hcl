packer {
  required_plugins {
    amazon = {
      version = ">= 1.2.8"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

variable "region" {
  type        = string
  description = "AWS region to build the AMI in"
  default     = "us-east-1"
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type for building the AMI (x86_64)"
  default     = "t3.micro"
}
variable "ssh_keypair_name" {
  type        = string
  description = "Name of the existing EC2 Key Pair to use for the Packer build instance"
  # Generated and imported as per README instructions
  default     = "ec2_ssh_key"
}

variable "ssh_private_key_file" {
  type        = string
  description = "Path to the private key file corresponding to the EC2 Key Pair"
  # Generated as per README: ./01-eks-cluster/private-key/ec2_ssh_key
  default     = "./01-eks-cluster/private-key/ec2_ssh_key"
}

variable "kubernetes_version" {
  type        = string
  description = "EKS Kubernetes version to pull the recommended AMI for"
  default     = "1.32"
}

variable "ami_ssm_type" {
  type        = string
  description = "AMI type path for SSM parameter lookup (AL2023 x86_64 standard)"
  default     = "amazon-linux-2023/x86_64/standard"
}

locals {
  # Terraform filter expects 1-32 (hyphen), not 1.32
  k8s_version_hyphen = replace(var.kubernetes_version, ".", "-")
  ami_name           = "al2023-eks-x86_64-${local.k8s_version_hyphen}-${formatdate("YYYYMMDD-hhmmss", timestamp())}"
}

data "amazon-parameterstore" "eks_al2023_x86_64_ami" {
  name             = "/aws/service/eks/optimized-ami/${var.kubernetes_version}/${var.ami_ssm_type}/recommended/image_id"
  with_decryption  = false
  region           = var.region
}

source "amazon-ebs" "eks_al2023_x86_64" {
  region        = var.region
  instance_type = var.instance_type

  ami_name        = local.ami_name
  ami_description = "EKS-optimized Amazon Linux 2023 x86_64 (K8s 1.32) with chrony installed"
  ami_groups      = []

  ssh_username = "ec2-user"
  ssh_keypair_name     = var.ssh_keypair_name
  ssh_private_key_file = var.ssh_private_key_file

  launch_block_device_mappings {
    device_name           = "/dev/xvda"
    volume_size           = 20
    volume_type           = "gp3"
    delete_on_termination = true
  }

  tags = {
    Name              = local.ami_name
    Project           = "tf-k8s-craftsman"
    Architecture      = "x86_64"
    BuiltWith         = "Packer"
    Base              = "EKS-Optimized-AL2023-1.32"
    KubernetesVersion = var.kubernetes_version
    CreationTimestamp = timestamp()
  }

  # Source AMI resolved from SSM Parameter via data source
  source_ami = data.amazon-parameterstore.eks_al2023_x86_64_ami.value
}

build {
  name    = "al2023-eks-x86_64-1-33"
  sources = ["source.amazon-ebs.eks_al2023_x86_64"]

  # Install and enable Chrony (NTP)
  provisioner "shell" {
    inline_shebang = "/bin/bash"
    expect_disconnect = true
    inline = [
      "set -euxo pipefail",
      "sudo dnf -y install chrony",
      "sudo systemctl enable --now chronyd"
    ]
  }
}
