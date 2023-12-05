variable "aws_region" {
  description = "The AWS region where resources will be created."
  type        = string
   default     = "us-east-1"
}

variable "ami_id" {
  description = "The ID of the Amazon Machine Image (AMI) to use for instances."
  type        = string
  default = ""
}
# Instance type
variable "instance_type" {
  default = {
    "prod"    = "t3.medium"
    "staging" = "t3.small"
  }
  description = "Type of the instance"
  type        = map(string)
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
variable "desired_capacity" {
  description = "The desired number of instances in the Auto Scaling Group."
  type        = number
  default = 2
}

variable "min_size" {
  description = "The minimum number of instances in the Auto Scaling Group."
  type        = number
  default     = 1 
}

variable "max_size" {
  description = "The maximum number of instances in the Auto Scaling Group."
  type        = number
  default     = 3
}
