resource "aws_s3_bucket" "terraform_state" {
  count = 1

  bucket = "${var.bucket_name_prefix}-${var.environment}"

  tags = {
    Environment = var.environment
  }
}
