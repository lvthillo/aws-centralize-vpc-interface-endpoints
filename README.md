# AWS Centralized VPC Interface Endpoints in Terraform

* Explain Role setup
* Remove account IDS from defaults
* For VPC endpoint policy, we select the default policy, however, in the production environment you may restrict access to the specific AWS Principals.
* https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_zone
* https://github.com/hashicorp/terraform-provider-aws/issues/10843
* https://globaldatanet.com/tech-blog/ssh-and-scp-with-aws-ssm
* https://github.com/qoomon/aws-ssm-ec2-proxy-command
* https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html
* Make more granular, for adding extra VPC, autto add sec groupos

scp awscliv2.zip ec2-user@i-060f5eea84c5ec02f:/home/ec2-user