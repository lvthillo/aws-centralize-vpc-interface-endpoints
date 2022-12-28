provider "aws" {
  alias  = "account_2"
  region = var.region
  assume_role {
    role_arn = "arn:aws:iam::${var.account_2["account_id"]}:role/${var.assumed_role}"
  }
}

module "network-2" {
  source = "./modules/network"
  providers = {
    aws = aws.account_2
  }
  vpc_name             = var.account_2["vpc_name"]
  vpc_cidr             = var.account_2["vpc_cidr"]
  azs                  = ["${var.region}a", "${var.region}b", "${var.region}c"]
  private_subnets_cidr = var.account_2["vpc_subnets"]
}

resource "aws_vpc_peering_connection" "owner-2" {
  provider      = aws.account_2
  vpc_id        = module.network-2.vpc_id
  peer_vpc_id   = module.network-1.vpc_id
  peer_owner_id = var.account_1["account_id"]
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

resource "aws_route" "peering_route_account_2_to_1" {
  provider                  = aws.account_2
  route_table_id            = module.network-2.private_route_table_id
  destination_cidr_block    = module.network-1.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.owner-2.id
  depends_on = [
    module.network-2.private_route_table_id
  ]
}
