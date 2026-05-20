# Main Terraform file for Distributed AI Inference Platform
# This file serves as the entry point for the infrastructure configuration

# All resources are defined in separate files for better organization:
# - provider.tf: AWS provider configuration
# - variables.tf: Input variables
# - vpc.tf: VPC, Internet Gateway, NAT Gateway
# - subnet.tf: Public and Private subnets with route tables
# - security.tf: Security groups for API and Worker servers
# - ec2.tf: EC2 instances configuration
# - outputs.tf: Output values

# To deploy this infrastructure:
# 1. terraform init
# 2. terraform plan
# 3. terraform apply
#
# To destroy:
# 1. terraform destroy
