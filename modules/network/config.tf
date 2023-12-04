terraform {
  backend "s3" {
    bucket = "impressive-neighbours-staging"
    key    = "network/terraform.tfstate"
    region = "us-east-1"
  }
}
