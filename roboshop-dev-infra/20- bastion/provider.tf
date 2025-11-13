terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.16.0"
    }
  }


  backend "s3" {
    bucket       = "teraform-state-repo"
    key          = "roboshop-dev-bastion"
    region       = "ap-south-1"
    use_lockfile = true
    encrypt      = true
  }


}

provider "aws" {
  # Configuration options
  region = "ap-south-1"
}

# refer : https://developer.hashicorp.com/terraform/language/backend/s3
