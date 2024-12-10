output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.custom.id
}

output "public_subnets" {
  description = "IDs of public subnets"
  value       = aws_subnet.public_subnets[*].id
}
