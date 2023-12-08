terraform {
  backend "s3" {
    bucket = "impressive-neighbours-staging-komal"
    key    = "network/terraform.tfstate"
    region = "us-east-1"
  }
}
