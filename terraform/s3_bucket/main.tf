resource "aws_s3_bucket" "terraform_state" {
  
  bucket = "${var.bucket_name_prefix}-${var.environment}-${var.bucket_name_sufix}"
   tags = {
    Environment = var.environment
  }
}

resource "aws_s3_bucket" "images" {
  
  bucket = "${var.bucket_name_prefix}-${var.environment}-image"
  tags = {
    Environment = var.environment
  }
}