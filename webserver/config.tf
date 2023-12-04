terraform {
  backend "s3" {
    bucket = "acs-project-in"      // Bucket where to SAVE Terraform State
    key    = "impressive-neighbour-prod-network/terraform.tfstate" // Object name in the bucket to SAVE Terraform State
    region = "us-east-1"                     // Region where bucket is created
  }
}