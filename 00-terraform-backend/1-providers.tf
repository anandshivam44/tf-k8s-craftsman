# Terraform Settings Block
terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 5.0"
     }
  }

  # random = {
  #     source  = "hashicorp/random"
  #     version = "~> 3.5.1"
  #   }
}

# Terraform Provider Block
provider "aws" {
  region = var.aws_region
}