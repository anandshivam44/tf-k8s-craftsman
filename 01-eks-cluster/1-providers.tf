# Terraform Settings Block
terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source = "hashicorp/aws"
      #version = "~> 4.12"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5.1"
    }
  }



  # Adding Backend as S3 for Remote State Storage
  backend "s3" {
    bucket = "terraform-backend-infra-dev20250906162054200000000001"
    key    = "dev/eks-cluster/terraform.tfstate"
    region = "us-east-1"

    # For State Locking
    dynamodb_table = "example-table-1"
  }

}

# Terraform Provider Block
provider "aws" {
  region = var.aws_region
}
