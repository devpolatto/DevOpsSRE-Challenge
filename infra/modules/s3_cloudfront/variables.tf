variable "config" {
  type = object({
    enabled                        = optional(bool, true)
    is_ipv6_enabled                = optional(bool, true)
    default_root_object            = optional(string, "index.html")
    aliases                        = optional(list(string), [])
    s3_bucket_domain_name          = string
    s3_bucket_id                   = string
    protocol_policy                = optional(string, "redirect-to-https")
    allowed_methods                = optional(list(string), ["GET", "HEAD", "OPTIONS"])
    cached_methods                 = optional(list(string), ["GET", "HEAD"])
    cloudfront_default_certificate = optional(bool, true)
    waf_acl_arn                    = optional(string, null)
    tags                           = optional(map(string), {})
  })
}