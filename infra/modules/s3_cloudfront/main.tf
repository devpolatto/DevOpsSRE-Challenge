resource "aws_cloudfront_origin_access_control" "this" {
  name                              = "oac-s3-${var.config.s3_bucket_domain_name}"
  description                       = "OAC para frontend estático"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "this" {
  enabled             = var.config.enabled
  is_ipv6_enabled     = var.config.is_ipv6_enabled
  default_root_object = var.config.default_root_object
  aliases             = var.config.aliases

  origin {
    domain_name              = var.config.s3_bucket_domain_name
    origin_id                = "S3-${var.config.s3_bucket_id}"
    origin_access_control_id = aws_cloudfront_origin_access_control.this.id

    # s3_origin_config {
    #   origin_access_identity = aws_cloudfront_origin_access_identity.this.cloudfront_access_identity_path
    # }
  }

  default_cache_behavior {
    target_origin_id       = "S3-${var.config.s3_bucket_id}"
    viewer_protocol_policy = var.config.protocol_policy
    allowed_methods        = var.config.allowed_methods
    cached_methods         = var.config.cached_methods

    forwarded_values {
      query_string = false
      cookies { forward = "none" }
    }

    min_ttl     = 0
    default_ttl = 86400
    max_ttl     = 31536000
    compress    = true
  }

  viewer_certificate {
    cloudfront_default_certificate = var.config.cloudfront_default_certificate
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  web_acl_id = var.config.waf_acl_arn

  tags = var.config.tags
}

resource "aws_cloudfront_origin_access_identity" "this" {}