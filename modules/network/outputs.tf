output "vpc_id" {
  value       = aws_vpc.vpc.id
  description = "The ID of the VPC"
}

output "default_vpc_sg" {
  value       = aws_vpc.vpc.default_security_group_id
  description = "Default security group of our VPC"
}