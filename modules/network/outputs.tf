output "vpc_id" {
  value       = aws_vpc.vpc.id
  description = "The ID of the VPC"
}

output "cidr_block" {
  value       = aws_vpc.vpc.cidr_block
  description = "The CIDR block of the VPC"
}

output "private_subnets" {
  value       = aws_subnet.private_subnet[*].id
  description = "List of ids of VPC private subnets"
}

output "private_route_table_id" {
  value       = aws_route_table.private_route_table.id
  description = "The id of the private route table"
}

output "default_vpc_sg" {
  value       = aws_vpc.vpc.default_security_group_id
  description = "Default security group of our VPC"
}