terraform {
  backend "s3" {
    bucket = "impressive-neighbours-production-komal"
    key    = "webserver/terraform.tfstate"
    region = "us-east-1"
  }
}
