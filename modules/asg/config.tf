terraform {
  backend "s3" {
    bucket = "impressive-neighbours-staging"
    key    = "asg/terraform.tfstate"
    region = "us-east-1"
  }
}
