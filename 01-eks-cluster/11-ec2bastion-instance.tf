data "aws_ssm_parameter" "al2023_ami" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

# IAM Role for Bastion Host to use SSM
resource "aws_iam_role" "bastion_ssm_role" {
  name = "${local.name}-bastion-ssm-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = local.common_tags
}

resource "aws_iam_role_policy_attachment" "bastion_ssm_core" {
  role       = aws_iam_role.bastion_ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "bastion_ssm" {
  name = "${local.name}-bastion-ssm-instance-profile"
  role = aws_iam_role.bastion_ssm_role.name
}

# AWS EC2 Instance Terraform Module
# Bastion Host - EC2 Instance that will be created in VPC Public Subnet
module "ec2_public" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "5.2.1"
  # insert the required variables here
  name                 = "${local.name}-BastionHost"
  ami                  = data.aws_ssm_parameter.al2023_ami.value
  instance_type        = var.instance_type
  key_name             = var.instance_keypair
  iam_instance_profile = aws_iam_instance_profile.bastion_ssm.name
  #monitoring             = true
  subnet_id              = module.vpc.public_subnets[0]
  vpc_security_group_ids = [module.public_bastion_sg.security_group_id]

  user_data = <<-EOF
#!/bin/bash
set -euxo pipefail
if command -v yum >/dev/null 2>&1; then
  sudo yum install -y amazon-ssm-agent || true
fi
sudo systemctl enable --now amazon-ssm-agent || true
EOF

  tags = local.common_tags
}