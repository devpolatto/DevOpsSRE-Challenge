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

resource "aws_iam_openid_connect_provider" "github" {
  url             = var.github_connection.url
  client_id_list  = var.github_connection.client_id_list
  thumbprint_list = var.github_connection.thumbprint_list
}

resource "aws_iam_role" "github_actions" {
  name               = "GitHubActions-Frontend-Deploy"
  assume_role_policy = data.aws_iam_policy_document.github_assume.json
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

resource "aws_iam_role_policy" "deploy" {
  role   = aws_iam_role.github_actions.id
  policy = data.aws_iam_policy_document.deploy.json
}

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

resource "github_actions_secret" "secrets" {
  for_each        = local.github_actions_secrets
  repository      = var.github_connection.repo_name
  secret_name     = each.value.secret_name
  plaintext_value = each.value.value
}