provider "aws" {
  region = "eu-west-1"
}

module "network-1" {
  source                 = "./../modules/network"
  vpc_name               = "vpc-1"
  vpc_cidr               = "10.0.0.0/16"
  azs                    = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
  private_subnets_cidr   = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}