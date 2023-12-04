terraform {
  backend "s3" {
    bucket = "impressive-neighbours-staging"
    key    = "webserver/terraform.tfstate"
    region = "us-east-1"
  }
}
