data "aws_caller_identity" "current" {}

# data "aws_cloudfront_distribution" "this" {
#   id         = module.s3_cloudfront.cloudfront.id
#   depends_on = [module.s3_cloudfront]
# }