terraform {
  backend "s3" {
    bucket = "impressive-neighbours-production-komal"
    key    = "network/terraform.tfstate"
    region = "us-east-1"
  }
}

resource "aws_dynamodb_table" "s3_lock_table" {
  name           = "S3LockTable"
  billing_mode   = "PROVISIONED"
  read_capacity  = 5
  write_capacity = 5

  attribute {
    name = "BucketName"
    type = "S"
  }

  hash_key = "BucketName"
}
