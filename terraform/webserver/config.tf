terraform {
  backend "s3" {
    bucket = "impressive-neighbours-staging-komal"
    key    = "webserver/terraform.tfstate"
    region = "us-east-1"
  }
}
