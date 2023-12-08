terraform {
  backend "s3" {
    bucket = "impressive-neighbours-staging"
    key    = "alb/terraform.tfstate"
    region = "us-east-1"
  }
}
