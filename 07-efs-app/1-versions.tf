# Terraform Settings Block
terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source = "hashicorp/aws"
      #version = "~> 4.13"
      version = "~> 5.0"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
      #version = "~> 2.11"
      version = "~> 2.22.0"
    }
  }
  # Adding Backend as S3 for Remote State Storage
  backend "s3" {
    bucket = "terraform-backend-infra-dev20250906162054200000000001"
    key    = "dev/efs-sampleapp-demo/terraform.tfstate"
    region = "us-east-1"

    # For State Locking
    dynamodb_table = "example-table-1"
  }
}

