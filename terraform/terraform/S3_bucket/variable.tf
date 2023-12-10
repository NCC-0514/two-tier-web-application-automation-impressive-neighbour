variable "environment" {
  description = "The environment name"
  default = "prod"
  type        = string
}
 
variable "bucket_name_prefix" {
  description = "Prefix for the S3 bucket name"
  default = "impressive-neighbours"
}
 
variable "bucket_name_sufix" {
  description = "Name of the person working on project"
}