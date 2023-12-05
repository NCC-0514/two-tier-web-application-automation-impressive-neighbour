variable "aws_region" {
  description = "The AWS region where resources will be created."
  type        = string
}

variable "ami_id" {
  description = "The ID of the Amazon Machine Image (AMI) to use for instances."
  type        = string
}

variable "instance_type" {
  description = "The type of EC2 instances to launch in the Auto Scaling Group."
  type        = string
}

variable "subnet_ids" {
  description = "A list of subnet IDs where instances will be launched."
  type        = list(string)
}

variable "asg_max_size" {
  description = "The maximum size of the Auto Scaling Group"
  type        = number
}

variable "asg_min_size" {
  description = "The minimum size of the Auto Scaling Group"
  type        = number
}

variable "asg_desired_capacity" {
  description = "The desired number of instances in the Auto Scaling Group"
  type        = number
}