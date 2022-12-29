variable "region" {
  description = "AWS region to which to deploy (should have 3 AZs!)"
}

variable "assumed_role" {
  description = "IAM Role to assume to deploy cross-account"
}

variable "vpc_endpoint_service_list" {
  description = "List of services for which to create interface vpc endpoints"
}

variable "account_1" {
  description = "Account ID of account which hosts interface endpoints"
}

variable "account_2" {
  description = "Account ID of account which connects to interface endpoints via account-1"
}

variable "account_3" {
  description = "Account ID of account which connects to interface endpoints via account-1"
}