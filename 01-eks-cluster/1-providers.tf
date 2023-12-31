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
    bucket = "terraform-backend-1691836809"
    key    = "dev/eks-cluster/terraform.tfstate"
    region = "us-east-1" 
 
    # For State Locking
    dynamodb_table = "01-eks-cluster"    
  }
    
}

# Terraform Provider Block
provider "aws" {
  region = var.aws_region
}