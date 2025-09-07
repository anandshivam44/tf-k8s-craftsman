
resource "aws_iam_role_policy_attachment" "eks-AmazonSSMManagedInstanceCore" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.eks_nodegroup_role.name
}
# IAM Role for EKS Node Group 
resource "aws_iam_role" "eks_nodegroup_role" {
  name = "${local.name}-eks-nodegroup-role"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "eks-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_nodegroup_role.name
}

resource "aws_iam_role_policy_attachment" "eks-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_nodegroup_role.name
}

resource "aws_iam_role_policy_attachment" "eks-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_nodegroup_role.name
}

# Least-privilege S3 access for SSM module staging used by Ansible over SSM
# Grants list on the bucket and put/get/delete within the ansible-staging/ prefix only
resource "aws_iam_policy" "eks_nodes_ssm_s3_access" {
  name        = "${local.name}-eks-ssm-s3-access"
  description = "Least-privilege S3 access for Ansible SSM staging (ansible-staging/ prefix only)"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid      = "ListBucketForStagingPrefix",
        Effect   = "Allow",
        Action   = ["s3:ListBucket"],
        Resource = "arn:aws:s3:::${var.ansible_staging_bucket_name}",
        Condition = {
          StringLike = {
            "s3:prefix" = [
              "${var.ansible_staging_prefix}*",
              "${var.ansible_staging_prefix}"
            ]
          }
        }
      },
      {
        Sid    = "ObjectAccessWithinStagingPrefix",
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:AbortMultipartUpload",
          "s3:DeleteObject"
        ],
        Resource = "arn:aws:s3:::${var.ansible_staging_bucket_name}/${var.ansible_staging_prefix}*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eks_nodes_ssm_s3_access_attach" {
  role       = aws_iam_role.eks_nodegroup_role.name
  policy_arn = aws_iam_policy.eks_nodes_ssm_s3_access.arn
}
