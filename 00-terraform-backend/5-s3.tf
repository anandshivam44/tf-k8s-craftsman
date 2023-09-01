resource "aws_s3_bucket" "terraform_backend_bucket" {
  bucket_prefix = "terraform-backend-${local.name}"
  acl    = "private"
  tags = local.common_tags
  force_destroy = true
}