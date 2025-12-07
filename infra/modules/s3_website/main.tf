resource "aws_s3_bucket" "this" {
  bucket = var.s3_bucket.bucket_name
}

resource "aws_s3_bucket_website_configuration" "this" {
  bucket = aws_s3_bucket.this.id
  index_document { suffix = var.s3_bucket.index_document }
  error_document { key = var.s3_bucket.error_document }
}

resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id
  versioning_configuration { status = var.s3_bucket.versioning_enabled ? "Enabled" : "Suspended" }
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

# OAI para CloudFront acessar o bucket
resource "aws_s3_bucket_policy" "oai" {
  bucket = aws_s3_bucket.this.id
  policy = data.aws_iam_policy_document.oai.json
}

data "aws_iam_policy_document" "oai" {
  statement {
    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.this.arn}/*"]
    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [var.s3_bucket.cloudfront_distribution_arn]
    }
  }
}

# Block public access
resource "aws_s3_bucket_public_access_block" "this" {
  count                   = var.s3_bucket.public_access_disable ? 1 : 0
  bucket                  = aws_s3_bucket.this.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}