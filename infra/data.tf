data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "deploy" {
  statement {
    actions = [
      "s3:PutObject",
      "s3:DeleteObject",
      "s3:ListBucket"
    ]
    resources = ["${module.s3_website.s3_bucket_website.bucket_arn}", "${module.s3_website.s3_bucket_website.bucket_arn}/*"]
  }

  statement {
    actions   = ["cloudfront:CreateInvalidation"]
    resources = [module.s3_cloudfront.cloudfront.arn]
  }
}

# https://docs.github.com/en/actions/how-tos/secure-your-work/security-harden-deployments/oidc-in-aws
data "aws_iam_policy_document" "github_assume" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github.arn]
    }
    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }
    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values = [
        "repo:${var.github_connection.owner}/${var.github_connection.repo_name}:ref:refs/heads/master",
        "repo:${var.github_connection.owner}/${var.github_connection.repo_name}:ref:refs/heads/main"
      ]
    }
  }
}