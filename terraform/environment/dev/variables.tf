# Provider Configuration
variable "region" {}

# Network Settings
variable "vpc_cidr" {}
variable "public_subnet_cidrs" {}
variable "private_subnet_cidrs" {}
variable "azs" {}

# Instance Settings
variable "ami_id" {}
variable "instance_type" {}
variable "devkey" {}

# Monitoring Configuration
variable "alert_email" {}