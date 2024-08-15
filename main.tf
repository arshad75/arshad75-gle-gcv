terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
  }
}

provider "aws" {
  region = var.region
}

# Configure the AWS Provider
provider "aws" {
  region = var.region
}

terraform {
  required_version = ">= 1.3.0"
}

module "vpc" {
  source  = "./modules/vpc"
  region                 = var.region
  vpc_cidr_block         = var.vpc_cidr_block
  public_subnet_cidrs    = var.public_subnet_cidrs
  private_subnet_cidrs   = var.private_subnet_cidrs
 create_vpc              = var.create_vpc
 tags                    = var.tags
}

module "eks" {
  source                            = "./modules/eks"
  region                            = var.region
  vpc_id                           = module.vpc.vpc_id
  private_subnet_ids               = module.vpc.private_subnet_ids
  enable_eks_managed_node_group   = var.enable_eks_managed_node_group
  eks_version                      = var.eks_version
  node_group_instance_types        = var.node_group_instance_types
  node_group_desired_capacity      = var.node_group_desired_capacity
 node_group_min_size              = var.node_group_min_size
  node_group_max_size              = var.node_group_max_size
  tags                             = var.tags
}