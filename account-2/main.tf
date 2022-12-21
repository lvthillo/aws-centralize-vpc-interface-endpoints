provider "aws" {
  region = "eu-west-1"
}

module "network-1" {
  source                 = "./../modules/network"
  vpc_name               = "vpc-1"
  vpc_cidr               = "192.168.0.0/16"
  azs                    = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
  private_subnets_cidr   = ["192.168.1.0/24", "192.168.2.0/24", "192.168.3.0/24"]
}

resource "aws_vpc_peering_connection" "owner" {
  vpc_id = module.network-1.outputs.vpc_id
  peer_vpc_id = "todo"
  peer_owner_id = "146926120857"
}