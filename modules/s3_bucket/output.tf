output "bucket_names" {
  value = [for i in aws_s3_bucket.terraform_state : i.bucket]
}