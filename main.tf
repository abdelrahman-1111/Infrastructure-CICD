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

module "my_network" {
  source               = "./network"
  vpc_region           = var.region
  vpc_CIDR             = var.vpc_CIDR
  public_subnet1_CIDR  = var.public_subnet1_CIDR
  public_subnet2_CIDR  = var.public_subnet2_CIDR
  private_subnet1_CIDR = var.private_subnet1_CIDR
  private_subnet2_CIDR = var.private_subnet2_CIDR

}
