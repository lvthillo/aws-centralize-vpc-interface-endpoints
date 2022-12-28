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
* Update the `assume_role` variable in `values.tfvars`
* Connect to `account-1`
* Run the following command
```
$ terraform apply -var-file values.tfvars
```

Check out this blog for more details.