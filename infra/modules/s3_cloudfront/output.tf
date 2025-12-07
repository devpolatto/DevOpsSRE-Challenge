output "cloudfront" {
  value = {
    domain_name = aws_cloudfront_distribution.this.domain_name
    arn         = aws_cloudfront_distribution.this.arn
  }
}