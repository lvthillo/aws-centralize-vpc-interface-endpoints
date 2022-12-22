provider "aws" {
  alias  = "account_2"
  region = var.region
  assume_role {
    role_arn = "arn:aws:iam::${var.account_2}:role/${var.assumed_role}"
  }
}

module "network-2" {
  source = "./modules/network"
  providers = {
    aws = aws.account_2
  }
  vpc_name             = "vpc-2"
  vpc_cidr             = "192.168.0.0/16"
  azs                  = ["${var.region}a", "${var.region}b", "${var.region}c"]
  private_subnets_cidr = ["192.168.1.0/24", "192.168.2.0/24", "192.168.3.0/24"]
}

resource "aws_vpc_peering_connection" "owner" {
  provider      = aws.account_2
  vpc_id        = module.network-2.vpc_id
  peer_vpc_id   = module.network-1.vpc_id
  peer_owner_id = var.account_1
}

resource "aws_route53_zone_association" "account_2_hosted_zone_association" {
  for_each = aws_route53_zone.interface_endpoint_private_hosted_zones
  provider = aws.account_2
  zone_id  = each.value.id
  vpc_id   = module.network-2.vpc_id
  depends_on = [
    aws_route53_vpc_association_authorization.vpc_authorization_account_2
  ]
}

resource "aws_route" "peering_route_account_2" {
  provider                  = aws.account_2
  route_table_id            = module.network-2.private_route_table_id
  destination_cidr_block    = module.network-1.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.owner.id
  depends_on = [
    module.network-2.private_route_table_id
  ]
}
