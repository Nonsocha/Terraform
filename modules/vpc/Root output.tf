output "instance_public_ip" {
  description = "Public IP of the EC2 instance"
  value       = aws_instance.web_server.public_ip
}

output "vpc_id" {
  description = "ID of the created VPC"
  value       = module.custom_vpc.vpc_id
}

