terraform {
  backend "s3" {
    bucket = "impressive-neighbours-staging"
    key    = "impressive-neighbour-modules-asg/terraform.tfstate"
    region = "us-east-1"
  }
}
