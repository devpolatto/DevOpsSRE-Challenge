module "s3_website" {
  source = "./modules/s3_website"

  s3_bucket = {
    bucket_name            = "${lower(replace(local.aws_prefix_name, "-", ""))}website"
    versioning_enabled     = true
    sse_encryption_enabled = true
    cloudfront_enabled     = false
  }
}

module "s3_cloudfront" {
  source = "./modules/s3_cloudfront"

  config = {
    s3_bucket_domain_name = module.s3_website.s3_bucket_website.regional_domain_name
    s3_bucket_id          = module.s3_website.s3_bucket_website.bucket_id
  }
}