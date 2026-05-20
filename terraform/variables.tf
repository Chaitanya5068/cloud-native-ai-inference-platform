variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "distributed-ai-inference-platform"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block for public subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "private_subnet_cidr" {
  description = "CIDR block for private subnet"
  type        = string
  default     = "10.0.2.0/24"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "enable_nat_gateway" {
  description = "Enable NAT Gateway for private subnet"
  type        = bool
  default     = true
}

variable "my_ip" {
  description = "Your IP address for SSH access (e.g., 203.0.113.0/32)"
  type        = string
  default     = "0.0.0.0/0" # Change this to your IP address for security
}

variable "ubuntu_ami" {
  description = "Ubuntu 22.04 AMI lookup"
  type        = string
  default     = "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"
}
