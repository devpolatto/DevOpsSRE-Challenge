module "sharedvariables" {
  source = "git::ssh://git@polattoxcodelearning/v3/polattoxcodelearning/Lab/TerraformModules//shared-variables?ref=main"
}

locals {
  azure_env = module.sharedvariables.envs["global"].azure
  aws_env   = module.sharedvariables.envs[var.environment]

  aws_region = module.sharedvariables.aws_regions[var.aws_config.region]

  aws_prefix_name = "${var.environment}-${local.aws_region}-SREChallenge"

  github_actions_secrets = {
    aws_role = {
      secret_name = "AWS_ROLE_ARN"
      value       = aws_iam_role.github_actions.arn
    }
    s3_bucket = {
      secret_name = "S3_BUCKET_NAME"
      value       = module.s3_website.s3_bucket_website.bucket_id
    }
    cloudfront = {
      secret_name = "CLOUDFRONT_DISTRIBUTION_ID"
      value       = module.s3_cloudfront.cloudfront.distribution_id
    }
    aws_region = {
      secret_name = "AWS_REGION"
      value       = var.aws_config.region
    }
    # aws_ecs_role = {
    #   secret_name = "AWS_ECS_ROLE_ARN"
    #   value       = try(aws_iam_role.github_actions_ecs.arn, "")
    # }
  }
}

variable "deploy_backend" {
  type    = bool
  default = false
}

variable "vpc" {
  type = object({
    cidr_block = string
  })
}

variable "github_connection" {
  type = object({
    url             = string
    client_id_list  = list(string)
    thumbprint_list = list(string)
    repo_name       = string
    owner           = string
  })
}

variable "github_token" {
  type      = string
  sensitive = true
}

variable "github_owner" {
  type      = string
  sensitive = true
}

variable "environment" {
  type = string
}

variable "aws_config" {
  type = object({
    profile = string
    region  = string
  })
  default = {
    profile = "dev"
    region  = "us-east-1"
  }
}

variable "tags" {
  type = map(string)
  default = {
    project         = "DevOpsSRE-Challenge"
    terraform       = "true"
    repository      = "DevOpsSRE-Challenge"
    repository_path = "DevOpsSRE-Challenge"
  }
}
