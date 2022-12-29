# Centralized VPC Interface Endpoints using Terraform

This example deploys a centralized VPC interface endpoint solution.

* `account-1`: AWS account where we create a VPC with private subnets and VPC interface endpoints for each service defined in `vpc_endpoint_service_list`.
* `account-2`: AWS account where we create a VPC with private subnets which is peered to the VPC in `account-1`. It makes use of the VPC interface endpoints deployed in the VPC of `account-1`.
* `account-3`: AWS account where we create a VPC with private subnets which is peered to the VPC in `account-1`. It makes use of the VPC interface endpoints deployed in the VPC of `account-1`.

![architecture-vpc-endpoints](https://user-images.githubusercontent.com/14105387/209798465-a75e716c-f233-456d-814e-a5f0e55dfea4.png)

## Deploy Solution

* Create 3 AWS accounts (`account-`1, `account-2`, `account-3`)
* Create a `deploy-role` with `AdministratorAccess` in each account. The `deploy-role` should be assumable from within `account-1`. The policy can be more restricted if you want to. Check here for your `terraform plan`
* Update the account IDs in `values.tfvars` to the IDs of the 3 accounts.
* Update the `assume_role` variable in `values.tfvars` to your `deploy-role`
* Connect to `account-1`
* Run the following command
```
$ terraform apply -var-file values.tfvars
```

Check out this blog for more details.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.48.0  |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws.account_1"></a> [aws.account\_1](#provider\_aws.account\_1) | 4.48.0 |
| <a name="provider_aws.account_2"></a> [aws.account\_2](#provider\_aws.account\_2) | 4.48.0 |
| <a name="provider_aws.account_3"></a> [aws.account\_3](#provider\_aws.account\_3) | 4.48.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_network-1"></a> [network-1](#module\_network-1) | ./modules/network | n/a |
| <a name="module_network-2"></a> [network-2](#module\_network-2) | ./modules/network | n/a |
| <a name="module_network-3"></a> [network-3](#module\_network-3) | ./modules/network | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_route.peering_route_account_1_to_2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route.peering_route_account_1_to_3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route.peering_route_account_2_to_1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route.peering_route_account_3_to_1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route53_record.interface_endpoint_record](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_vpc_association_authorization.vpc_authorization_account_2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_vpc_association_authorization) | resource |
| [aws_route53_vpc_association_authorization.vpc_authorization_account_3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_vpc_association_authorization) | resource |
| [aws_route53_zone.interface_endpoint_private_hosted_zones](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_zone) | resource |
| [aws_route53_zone_association.account_2_hosted_zone_association](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_zone_association) | resource |
| [aws_route53_zone_association.account_3_hosted_zone_association](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_zone_association) | resource |
| [aws_security_group.interface_endpoint_sgs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group_rule.allow_vpc_account_1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.allow_vpc_account_2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.allow_vpc_account_3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_vpc_endpoint.vpc_interface_endpoints](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [aws_vpc_peering_connection.owner-2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_peering_connection) | resource |
| [aws_vpc_peering_connection.owner-3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_peering_connection) | resource |
| [aws_vpc_peering_connection_accepter.accepter-2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_peering_connection_accepter) | resource |
| [aws_vpc_peering_connection_accepter.accepter-3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_peering_connection_accepter) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_1"></a> [account\_1](#input\_account\_1) | Account ID of which hosts interface endpoints | `any` | n/a | yes |
| <a name="input_account_2"></a> [account\_2](#input\_account\_2) | Account ID of account which connects to interface endpoints via account-1 | `any` | n/a | yes |
| <a name="input_account_3"></a> [account\_3](#input\_account\_3) | Account ID of account which connects to interface endpoints via account-1 | `any` | n/a | yes |
| <a name="input_assumed_role"></a> [assumed\_role](#input\_assumed\_role) | IAM Role to assume to deploy cross-account | `any` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | AWS region to which to deploy (should have 3 AZs!) | `any` | n/a | yes |
| <a name="input_vpc_endpoint_service_list"></a> [vpc\_endpoint\_service\_list](#input\_vpc\_endpoint\_service\_list) | List of services for which to create interface vpc endpoints | `any` | n/a | yes |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->