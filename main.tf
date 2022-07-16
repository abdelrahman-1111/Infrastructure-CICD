terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>3.0"
    }
  }

  backend "s3" {
    bucket = "iti-course-terraformstate"
    key    = "terraform.tfstate"
    region = "us-east-1"

  }
}
provider "aws" {
  region = "us-east-1"
}

module network {

  source = "./network"
  module.vpc-region  = var.region
  module.vpc_CIDR = var.vpc_CIDR
  module.public_subnet1_CIDR = var.public_subnet1_CIDR
  module.public_subnet2_CIDR = var.public_subnet2_CIDR
  module.private_subnet1_CIDR = var.private_subnet1_CIDR
  module.private_subnet2_CIDR = var.private_subnet2_CIDR
  
}
