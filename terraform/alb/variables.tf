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

# Variable to signal the current environment 
variable "env" {
  default     = "staging"
  type        = string
  description = "Deployment Environment"
}

# Prefix for alb name
variable "alb_name_prefix" {
  default     = "Impressive"
  type        = string
  description = "Prefix for ALB resource names"
}