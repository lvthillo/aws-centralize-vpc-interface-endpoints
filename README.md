# Centralized VPC Interface Endpoints using Terraform
This example deploys a centralized vpC interface endpoint solution.

* `account-1`: AWS account where we create a VPC with private subnets and VPC interface endpoints for each service defined in `vpc_endpoint_service_list`
* `account-2`: AWS account where we create a VPC with private subnets which is peered to the VPC in `account-1`. It makes use of the VPC interface endpoints deployed in the VPC of `account-1`.
* `account-3`: AWS account where we create a VPC with private subnets which is peered to the VPC in `account-1`. It makes use of the VPC interface endpoints deployed in the VPC of `account-1`.

## Requirements
* Terraform (AWS Provider dependency)
* 3 AWS accounts
* A cross-account deploy role

## Role dependency
This solution depends on an `assumed_role` variable. This should be the name of an IAM role which exists in each of the 3 accounts.
The account in which the interface endpoints are created should be able to assume those cross-account IAM roles.
The role should have the `PowerUserAccess` managed policy attached. It can be more restricted if you want to.

## How to apply the solution?
1) Create the `assumed_role` in each of the 3 accounts.
2) Add the 3 `account_ids` to `values.tfvars`.
3) Optional: Update the other values in `values.tfvars`.
4) Connect to `account-1`.
5) Run `terraform init` to download the provider dependency.
6) Run `terraform plan -var-file values.tfvars` to see what will be deployed.
7) Run `terraform apply -var-file values.tfvars` to create the stack.

## Terraform drawbacks
We use the `assumed_role` to configure a provider for each of the 3 AWS accounts. 
```
provider "aws" {
  alias  = "account_1"
  region = var.region
  assume_role {
    role_arn = "arn:aws:iam::${var.account_1["account_id"]}:role/${var.assumed_role}"
  }
}

```
Next, we use this provider to make clear which resource or module should be deployed to which AWS account.
```
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
```

Some drawbacks of Terraform providers:
* [You can't use dynamic provider assignmets](https://github.com/hashicorp/terraform/issues/25244).
* [You can't pass providers to for_each in a module](https://github.com/hashicorp/terraform/issues/24476)

Those drawbacks force me to "duplicate" resources. I have to define a resource twice (with a differenet provider) instead of using dynamic solutions. This makes the solution less reusable, still it's not too hard to add VPCs/accounts.

## Test Setup
To test the setup I want to connect to an EC2 instance in the VPC created in `account-2` and send a message to an SQS queue. Also create the SQS queue in `account-2`.
The whole solution is private, there are no NAT gateways or Internet Gateways. This means that we can only connect to an EC2 using [Session Manager and its interface VPC endpoints](https://aws.amazon.com/premiumsupport/knowledge-center/ec2-systems-manager-vpc-endpoints/). 

Here for we need VPC endpoints for:
* ssm
* ssmmessages
* ec2messages

Deploy an EC2 in a private subnet and attach an IAM role which has SQS access and the managed `AmazonSSMManagedInstanceCore` policy attached.
If the solution is deployed correctly, then you can just connect to your EC2 instance using Session Manager.
Now most AWS EC2s hav AWS CLI v1 installed. AWS CLI v1 connects to a deprecated endpoint for SQS, so we need to install AWS CLI v2 on the EC2.
Our instance has no internet access so we will `scp` the installer to the instance using Session Manager.

```
$ scp awscliv2.zip ec2-user@i-02a902a38fcd4859e:/home/ec2-user/
Add public key /Users/xxx/.ssh/id_rsa.pub for ec2-user at instance i-02a902a38fcd4859e for 60 seconds
Start ssm session to instance i-02a902a38fcd4859e
...
```

[Install AWS CLI v2](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) on the instance.
```
$ ssh ec2-user@i-02a902a38fcd4859e
$ aws --version
aws-cli/2.9.9 Python/3.9.11 Linux/5.10.157-139.675.amzn2.x86_64 exe/x86_64.amzn.2 prompt/off
$ aws sqs send-message --queue-url https://sqs.eu-west-1.amazonaws.com/<account-id>/demo-queue --message-body "Test" --region eu-west-1
{
    "MD5OfMessageBody": "c454552d52d55d3ef56408742887362b",
    "MessageId": "4e298fdf-e9c0-492f-95e7-bfb2c55a4bf9"
}
$ nslookup sqs.eu-west-1.amazonaws.com
Server:		192.168.100.2
Address:	192.168.100.2#53

Non-authoritative answer:
Name:	sqs.eu-west-1.amazonaws.com
Address: 10.0.3.201
Name:	sqs.eu-west-1.amazonaws.com
Address: 10.0.1.183
Name:	sqs.eu-west-1.amazonaws.com
Address: 10.0.2.157
``` 

See the docs to configure your terminal to use Session Manager:
* https://globaldatanet.com/tech-blog/ssh-and-scp-with-aws-ssm
* https://github.com/qoomon/aws-ssm-ec2-proxy-command




### Additional Remarks
* For VPC endpoint policy, we select the default policy, however, in the production environment you may restrict access to the specific AWS Principals.
* You can put `account-3` related resources in comment to deploy only to 2 accounts.