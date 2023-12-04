# Default tags
variable "default_tags" {
  default     = {"Owner" = "IN", "App" = "Web"}
  type        = map(any)
  description = "Default tags to be applied to all AWS resources"
}

# Name prefix
variable "prefix" {
  default     = "Impressive"
  type        = string
  description = "Name prefix"
}

# Provision public subnets in custom VPC
variable "public_subnet_cidrs" {
  default     = ["10.200.0.0/24", "10.200.1.0/24","10.200.2.0/24"]
  type        = list(string)
  description = "Public Subnet CIDRs"
}

# Provision private subnets in custom VPC
variable "private_subnet_cidrs" {
  default     = ["10.200.3.0/24", "10.200.4.0/24", "10.200.5.0/24"]
  type        = list(string)
  description = "Private Subnet CIDRs"
}

# VPC CIDR range
variable "vpc_cidr" {
  default     = "10.200.0.0/16"
  type        = string
  description = "VPC to host static web site"
}

# Variable to signal the current environment 
variable "env" {
  default     = "staging"
  type        = string
  description = "Deployment Environment"
}


# Instance type for ASG
variable "instance_type" {
  description = "Instance type for the EC2 instances in the ASG"
  type        = string
  default     = "t2.micro"  # Or your desired instance type
}

# ASG size configurations
variable "asg_min_size" {
  description = "Minimum size of the Auto Scaling Group"
  type        = number
  default     = 1
}

variable "asg_max_size" {
  description = "Maximum size of the Auto Scaling Group"
  type        = number
  default     = 3
}

variable "asg_desired_capacity" {
  description = "Desired capacity of the Auto Scaling Group"
  type        = number
  default     = 2
}

