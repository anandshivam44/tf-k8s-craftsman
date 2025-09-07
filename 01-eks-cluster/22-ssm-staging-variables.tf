# Variables for Ansible SSM S3 staging
# Note: The backend "s3" block in providers cannot use variables, so defaults are set to match the configured backend.

variable "ansible_staging_bucket_name" {
  description = "S3 bucket name used by Ansible SSM connection for module/file staging"
  type        = string
  default     = "terraform-backend-infra-dev20250906162054200000000001"
}

variable "ansible_staging_prefix" {
  description = "S3 key prefix within the staging bucket for Ansible over SSM"
  type        = string
  default     = "ansible-staging/"
}
