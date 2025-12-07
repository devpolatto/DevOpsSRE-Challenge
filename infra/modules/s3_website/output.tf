output "s3_bucket_website" {
  value = {
    bucket_name          = aws_s3_bucket.this.bucket
    bucket_arn           = aws_s3_bucket.this.arn
    bucket_id            = aws_s3_bucket.this.id
    regional_domain_name = aws_s3_bucket.this.bucket_regional_domain_name
    website_endpoint     = aws_s3_bucket_website_configuration.this.website_endpoint
    oia_policy           = aws_s3_bucket_policy.oai.policy
  }
}