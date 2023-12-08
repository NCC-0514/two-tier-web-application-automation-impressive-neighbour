# Instance type
variable "instance_type" {
  default = {
    "prod"    = "t3.medium"
    "staging" = "t3.small"
  }
  description = "Type of the instance"
  type        = map(string)
}

# Default tags
variable "default_tags" {
  default     = {"Owner" = "IN", "App" = "Web"}
  type        = map(any)
  description = "Default tags to be applied to all AWS resources"
}

# Variable to signal the current environment 
variable "env" {
  default     = "staging"
  type        = string
  description = "Deployment Environment"
}

# Name prefix
variable "prefix" {
  default     = "Impressive"
  type        = string
  description = "Name prefix"
}

variable "service_ports" {
  type        = list(string)
  default     = ["22"]
  description = "Ports that should be open on a webserver"
}

# Prefix for alb name
variable "alb_name_prefix" {
  default     = "Impressive"
  type        = string
  description = "Prefix for ALB resource names"
}

variable "alb_ports" {
  type        = list(string)
  default     = ["80"]
  description = "Ports that should be open on a webserver"
}

