output "bucket_names" {
  value = aws_s3_bucket.terraform_state.id
}

output "image_bucket" {
    value = aws_s3_bucket.images.id
}