provider "aws" {
  region = local.region
}

# TODO: Update this snippet
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name               = "${local.name}-vpc"
  cidr               = "124.16.0.0/16"
  azs                = ["ap-southeast-1a", "ap-southeast-1b", "ap-southeast-1c"]
  public_subnets     = ["124.16.0.0/20", "124.16.16.0/20", "124.16.32.0/20"]
  private_subnets    = ["124.16.128.0/20", "124.16.144.0/20", "124.16.160.0/20"]
  enable_nat_gateway = true
}

