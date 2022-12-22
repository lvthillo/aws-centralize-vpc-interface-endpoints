variable "vpc_name" {
  description = "Name for VPC"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR for VPC"
  type        = string
}

variable "azs" {
  description = "AZs in which subnets will be deployed"
  type        = list(string)
}

variable "private_subnets_cidr" {
  description = "Private subnets in VPC"
  type        = list(string)
}