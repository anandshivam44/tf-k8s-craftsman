# EC2 Key Pair for EKS worker nodes SSH access
# Uses the existing public key located at private-key/ec2_ssh_key.pub by default

resource "aws_key_pair" "eks_key" {
  key_name   = var.ec2_ssh_key_name
  public_key = file("${path.module}/private-key/${var.ec2_ssh_key_name}.pub")
}
