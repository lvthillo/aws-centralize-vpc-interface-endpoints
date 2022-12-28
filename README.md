# Centralized VPC Interface Endpoints using Terraform

This example deploys a centralized VPC interface endpoint solution.

* `account-1`: AWS account where we create a VPC with private subnets and VPC interface endpoints for each service defined in `vpc_endpoint_service_list`.
* `account-2`: AWS account where we create a VPC with private subnets which is peered to the VPC in `account-1`. It makes use of the VPC interface endpoints deployed in the VPC of `account-1`.
* `account-3`: AWS account where we create a VPC with private subnets which is peered to the VPC in `account-1`. It makes use of the VPC interface endpoints deployed in the VPC of `account-1`.

![architecture-vpc-endpoints](https://user-images.githubusercontent.com/14105387/209798465-a75e716c-f233-456d-814e-a5f0e55dfea4.png)

Check out this blog for more details.