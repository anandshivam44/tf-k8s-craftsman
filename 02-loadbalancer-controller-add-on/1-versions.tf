# Terraform Settings Block
terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 5.0"
     }
    helm = {
      source = "hashicorp/helm"
      version = "~> 2.10.1"
    }
    http = {
      source = "hashicorp/http"
      version = "~> 3.4.0"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "~> 2.22.0"
    }      
  }
  # Adding Backend as S3 for Remote State Storage
  backend "s3" {
    bucket = "terraform-backend-1691836809"
    key    = "dev/aws-lbc/terraform.tfstate"
    region = "us-east-1" 

    # For State Locking
    dynamodb_table = "02-lbc-install-terraform-manifests"    
  }     
}

# Terraform AWS Provider Block
provider "aws" {
  region = var.aws_region
}

# Terraform HTTP Provider Block
provider "http" {
  # Configuration options
}