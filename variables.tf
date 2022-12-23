variable "region" {
  description = "AWS region to which to deploy (should have 3 AZs!)"
  default     = "eu-west-1"
}

variable "assumed_role" {
  description = "IAM Role to assume to deploy cross-account"
  default     = "deploy-role"
}

variable "account_1" {
  description = "Account ID of which hosts interface endpoints"
}

variable "account_2" {
  description = "Account ID of account which connects to interface endpoints via account-1"
}

variable "vpc_endpoint_service_list" {
  description = "List of services for which to create interface vpc endpoints"
  default     = ["sqs", "ssm", "ec2messages", "ssmmessages", "kms"]
}