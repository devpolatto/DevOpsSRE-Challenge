resource "aws_s3_bucket" "this" {
  bucket = var.s3_bucket.bucket_name
}

resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id
  versioning_configuration {
    status = var.s3_bucket.versioning_enabled ? "Enabled" : "Suspended"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  count  = var.s3_bucket.sse_encryption_enabled ? 1 : 0
  bucket = aws_s3_bucket.this.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "this" {
  count                   = var.s3_bucket.public_access_disable ? 1 : 0
  bucket                  = aws_s3_bucket.this.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# NOVO: Política permitindo acesso ao CloudFront OAC
# resource "aws_s3_bucket_policy" "oac_policy" {
#   bucket = aws_s3_bucket.this.id
#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Effect = "Allow"
#         Principal = {
#           Service = "cloudfront.amazonaws.com"
#         }
#         Action = [
#           "s3:GetObject"
#         ]
#         Resource = "arn:aws:s3:::${var.s3_bucket.bucket_name}/*"
#         Condition = {
#           StringEquals = {
#             "AWS:SourceArn" = var.s3_bucket.cloudfront_distribution_arn
#           }
#         }
#       }
#     ]
#   })
# }
