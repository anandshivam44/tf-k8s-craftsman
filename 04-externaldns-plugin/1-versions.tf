# Terraform Settings Block
terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source = "hashicorp/aws"
      #version = "~> 4.12"
      version = "~> 5.0"
     }
    helm = {
      source = "hashicorp/helm"
      #version = "2.5.1"
      #version = "~> 2.5"
      version = "~> 2.10.1"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
      #version = "~> 2.11"
      version = "~> 2.22.0"
    }      
  }
  # Adding Backend as S3 for Remote State Storage
  backend "s3" {
    bucket = "terraform-backend-1691836809"
    key    = "dev/aws-externaldns/terraform.tfstate"
    region = "us-east-1" 

    # For State Locking
    dynamodb_table = "03-externaldns-install-terraform-manifests"    
  }     
}

# Terraform AWS Provider Block
provider "aws" {
  region = var.aws_region
}

