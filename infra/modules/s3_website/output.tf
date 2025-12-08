output "s3_bucket_website" {
  value = {
    bucket_name          = aws_s3_bucket.this.bucket
    bucket_arn           = aws_s3_bucket.this.arn
    bucket_id            = aws_s3_bucket.this.id
    bucket_domain_name   = aws_s3_bucket.this.bucket_domain_name
    regional_domain_name = aws_s3_bucket.this.bucket_regional_domain_name
  }
}