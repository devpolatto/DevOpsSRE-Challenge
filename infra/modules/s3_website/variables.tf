variable "s3_bucket" {
  description = <<EOT
     Configuration for the S3 bucket
     properties:
      - bucket_name: The name of the S3 bucket
      - versioning_enabled: Enable or disable versioning for the bucket
      - sse_encryption_enabled: Enable or disable server-side encryption
      - cloudfront_enabled: Enable or disable CloudFront integration
      - cloudfront_distribution_arn (if cloudfront_enabled is true): ARN of the CloudFront distribution
      - index_document: The index document for the website hosting
      - error_document: The error document for the website hosting
     EOT
  type = object({
    bucket_name                 = string
    versioning_enabled          = optional(bool, true)
    sse_encryption_enabled      = optional(bool, true)
    cloudfront_enabled          = optional(bool, false)
    cloudfront_distribution_arn = optional(string, "")
    index_document              = optional(string, "index.html") # Added default index document
    error_document              = optional(string, "error.html") # Added default error document
    public_access_disable       = optional(bool, true)
  })
}