provider "aws" {
  alias  = "account_1"
  region = var.region
  assume_role {
    role_arn = "arn:aws:iam::${var.account_1["account_id"]}:role/${var.assumed_role}"
  }
}

########################################
## Central Account specific resources ##
########################################
module "network-1" {
  source = "./modules/network"
  providers = {
    aws = aws.account_1
  }
  vpc_name             = var.account_1["vpc_name"]
  vpc_cidr             = var.account_1["vpc_cidr"]
  azs                  = ["${var.region}a", "${var.region}b", "${var.region}c"]
  private_subnets_cidr = var.account_1["vpc_subnets"]
}

resource "aws_vpc_endpoint" "vpc_interface_endpoints" {
  for_each          = toset(var.vpc_endpoint_service_list)
  provider          = aws.account_1
  vpc_id            = module.network-1.vpc_id
  service_name      = "com.amazonaws.${var.region}.${each.value}"
  vpc_endpoint_type = "Interface"

  security_group_ids = [
    aws_security_group.interface_endpoint_sgs[each.value].id,
  ]

  subnet_ids          = module.network-1.private_subnets
  private_dns_enabled = false
}

resource "aws_security_group" "interface_endpoint_sgs" {
  for_each    = toset(var.vpc_endpoint_service_list)
  provider    = aws.account_1
  name        = "${each.key}-sg"
  description = "Allow TLS inbound traffic to interface endpoint"
  vpc_id      = module.network-1.vpc_id
}

resource "aws_security_group_rule" "allow_vpc_account_1" {
  for_each          = aws_security_group.interface_endpoint_sgs
  provider          = aws.account_1
  description       = "Allow HTTPS traffic from VPC 1"
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = [module.network-1.cidr_block]
  security_group_id = each.value.id
}

resource "aws_route53_zone" "interface_endpoint_private_hosted_zones" {
  for_each = toset(var.vpc_endpoint_service_list)
  provider = aws.account_1
  name     = "${each.key}.${var.region}.amazonaws.com"
  comment  = "Private hosted zone for ${each.key} Interface Endpoint"

  vpc {
    vpc_id = module.network-1.vpc_id
  }

  # See issue: https://github.com/hashicorp/terraform-provider-aws/issues/10843
  # See remark: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_zone
  lifecycle {
    ignore_changes = [vpc]
  }
}

resource "aws_route53_record" "interface_endpoint_record" {
  for_each = toset(var.vpc_endpoint_service_list)
  provider = aws.account_1
  zone_id  = aws_route53_zone.interface_endpoint_private_hosted_zones[each.value].zone_id
  name     = "${each.value}.${var.region}.amazonaws.com"
  type     = "A"
  alias {
    name                   = aws_vpc_endpoint.vpc_interface_endpoints[each.value].dns_entry[0]["dns_name"]
    zone_id                = aws_vpc_endpoint.vpc_interface_endpoints[each.value].dns_entry[0]["hosted_zone_id"]
    evaluate_target_health = false
  }
}

#########################
## Duplicate resources ##
#########################
resource "aws_vpc_peering_connection_accepter" "accepter-2" {
  provider                  = aws.account_1
  vpc_peering_connection_id = aws_vpc_peering_connection.owner-2.id
  auto_accept               = true
}

resource "aws_vpc_peering_connection_accepter" "accepter-3" {
  provider                  = aws.account_1
  vpc_peering_connection_id = aws_vpc_peering_connection.owner-3.id
  auto_accept               = true
}

resource "aws_route" "peering_route_account_1_to_2" {
  provider                  = aws.account_1
  route_table_id            = module.network-1.private_route_table_id
  destination_cidr_block    = module.network-2.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.owner-2.id
  depends_on = [
    module.network-1.private_route_table_id
  ]
}

resource "aws_route" "peering_route_account_1_to_3" {
  provider                  = aws.account_1
  route_table_id            = module.network-1.private_route_table_id
  destination_cidr_block    = module.network-3.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.owner-3.id
  depends_on = [
    module.network-1.private_route_table_id
  ]
}

resource "aws_route53_vpc_association_authorization" "vpc_authorization_account_2" {
  for_each = aws_route53_zone.interface_endpoint_private_hosted_zones
  provider = aws.account_1
  vpc_id   = module.network-2.vpc_id
  zone_id  = each.value.id
}

resource "aws_route53_vpc_association_authorization" "vpc_authorization_account_3" {
  for_each = aws_route53_zone.interface_endpoint_private_hosted_zones
  provider = aws.account_1
  vpc_id   = module.network-3.vpc_id
  zone_id  = each.value.id
}

resource "aws_security_group_rule" "allow_vpc_account_2" {
  for_each          = aws_security_group.interface_endpoint_sgs
  provider          = aws.account_1
  description       = "Allow HTTPS traffic from VPC 2"
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = [module.network-2.cidr_block]
  security_group_id = each.value.id
}

resource "aws_security_group_rule" "allow_vpc_account_3" {
  for_each          = aws_security_group.interface_endpoint_sgs
  provider          = aws.account_1
  description       = "Allow HTTPS traffic from VPC 2"
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = [module.network-3.cidr_block]
  security_group_id = each.value.id
}