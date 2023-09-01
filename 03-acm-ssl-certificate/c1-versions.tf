# Terraform Settings Block
terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 5.0"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "~> 2.22.0"
    }  
  }
  # Adding Backend as S3 for Remote State Storage
  backend "s3" {
    bucket = "terraform-backend-1691836809"
    key    = "dev/aws-lbc-ingress/terraform.tfstate"
    region = "us-east-1" 

    # For State Locking
    dynamodb_table = "04-kube-manifests-ingress-groups"    
  }    
}

# CLEAN PROVIDERS 
