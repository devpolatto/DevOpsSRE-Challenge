output "s3_website" {
  value = module.s3_website.s3_bucket_website
}

output "s3_cloudfront" {
  value = module.s3_cloudfront.cloudfront
}