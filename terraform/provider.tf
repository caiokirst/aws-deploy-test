terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  
  backend "s3" {
    bucket = "aws-deploy-caiokirst" 
    key    = "wazuh/terraform.tfstate"
    region = "sa-east-1"
  }
}

provider "aws" {
  region = var.aws_region
  default_tags {
    tags = {
      Environment = "Assessment"
      Project     = "DefensePoint-Security"
      ManagedBy   = "Terraform"
    }
  }
}