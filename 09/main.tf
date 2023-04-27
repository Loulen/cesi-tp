terraform {
  required_version = "~> 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = var.region

  default_tags {
    tags = {
      School  = var.school
      Project = var.project
    }
  }
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = lower("${var.school}-${var.project}-vpc")
  cidr = "10.0.0.0/16"

  azs             = ["${var.region}a", "${var.region}b", "${var.region}c"]
  private_subnets = ["10.0.96.0/19", "10.0.128.0/19", "10.0.160.0/19"]
  public_subnets  = ["10.0.0.0/19", "10.0.32.0/19", "10.0.64.0/19"]

  enable_nat_gateway = true
  enable_vpn_gateway = false

  tags = {
    Name = lower("${var.school}-${var.project}-vpc")
  }
}

module "compute" {
  source = "./modules/compute"

  school          = var.school
  project         = var.project
  vpc_id          = module.vpc.vpc_id
  public_subnets  = module.vpc.public_subnets
  private_subnets = module.vpc.private_subnets
}
