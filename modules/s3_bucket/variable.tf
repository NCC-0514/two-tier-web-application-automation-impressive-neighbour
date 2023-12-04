variable "environment" {
  description = "The environment name"
  default = "staging"
  type        = string
}

variable "bucket_name_prefix" {
  description = "Prefix for the S3 bucket name"
  default = "impressive-neighbours"
}