output "api_server_public_ip" {
  description = "Public IP address of the API server"
  value       = aws_instance.api_server.public_ip
}

output "api_server_private_ip" {
  description = "Private IP address of the API server"
  value       = aws_instance.api_server.private_ip
}

output "worker_server_private_ip" {
  description = "Private IP address of the worker server"
  value       = aws_instance.worker_server.private_ip
}

output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "vpc_cidr" {
  description = "VPC CIDR block"
  value       = aws_vpc.main.cidr_block
}

output "public_subnet_id" {
  description = "Public subnet ID"
  value       = aws_subnet.public.id
}

output "private_subnet_id" {
  description = "Private subnet ID"
  value       = aws_subnet.private.id
}

output "api_security_group_id" {
  description = "API server security group ID"
  value       = aws_security_group.api_sg.id
}

output "worker_security_group_id" {
  description = "Worker server security group ID"
  value       = aws_security_group.worker_sg.id
}

output "api_server_ssh_command" {
  description = "SSH command to connect to API server"
  value       = "ssh -i your-key.pem ubuntu@${aws_instance.api_server.public_ip}"
}

output "api_server_url" {
  description = "Base URL for API server"
  value       = "http://${aws_instance.api_server.public_ip}"
}
