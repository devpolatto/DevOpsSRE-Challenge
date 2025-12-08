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
    s3_bucket_domain_name = module.s3_website.s3_bucket_website.bucket_domain_name
    s3_bucket_id          = module.s3_website.s3_bucket_website.bucket_id
    depends_on            = [module.s3_website]
  }
}

resource "aws_s3_bucket_policy" "oac_policy" {
  bucket = module.s3_website.s3_bucket_website.bucket_name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action = [
          "s3:GetObject"
        ]
        Resource = "arn:aws:s3:::${module.s3_website.s3_bucket_website.bucket_name}/*"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = module.s3_cloudfront.cloudfront.arn
          }
        }
      }
    ]
  })
  depends_on = [module.s3_website, module.s3_cloudfront]
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

resource "aws_iam_role_policy" "deploy" {
  role   = aws_iam_role.github_actions.id
  policy = data.aws_iam_policy_document.deploy.json
}

module "vpc" {
  source = "./modules/vpc"

  vpc = {
    name       = "${local.aws_prefix_name}-vpc"
    cidr_block = var.vpc.cidr_block
  }
  tags = {
    Environment = var.environment
  }
}

module "ecr" {
  source = "./modules/ecr"

  repository = {
    name                 = "${lower(replace(local.aws_prefix_name, "-", ""))}repository"
    image_tag_mutability = "IMMUTABLE"
    scan_on_push         = true
  }
  tags = {
    Environment = var.environment
  }
}

resource "aws_iam_role_policy" "ecs_deploy" {
  name = "${local.aws_prefix_name}-GitHubActions-ECS-Deploy"
  role = aws_iam_role.github_actions.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecr:CompleteLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:InitiateLayerUpload",
          "ecr:BatchDeleteImage",
          "ecr:PutImage",
          "ecr:BatchCheckLayerAvailability"
        ]
        Resource = module.ecr.repository.repository_arn
      },
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ecs:UpdateService"
        ]
        Resource = "arn:aws:ecs:*:${data.aws_caller_identity.current.account_id}:service/${local.aws_prefix_name}-cluster/${local.aws_prefix_name}-service"
      },
      {
        Effect = "Allow"
        Action = [
          "ecs:DescribeServices",
          "ecs:DescribeTaskDefinition"
        ]
        Resource = "*"
        Condition = {
          StringEquals = {
            "ecs:cluster" = "arn:aws:ecs:*:${data.aws_caller_identity.current.account_id}:cluster/${local.aws_prefix_name}-cluster"
          }
        }
      }
    ]
  })
}

module "rds_aurora" {
  source = "./modules/aurora"

  aurora = {
    name = "prodaurora"
  }
  write_cluster_instence = {
    enabled = true
  }
  reader_cluster_instence = {
    enabled = false
  }
  secret = {
    secret_name = "${local.aws_prefix_name}-aurora-secret"
  }
  network = {
    vpc_security_group_ids = [aws_security_group.aurora.id]
    db_subnet_group_name   = aws_db_subnet_group.this.name
  }
  tags = {
    Environment = var.environment
  }
}

module "ecs" {
  source = "./modules/ecs"

  ecr = {
    repository_url = module.ecr.repository.uri
  }
  network = {
    subnets                        = module.vpc.private_subnets.ids
    security_groups                = [aws_security_group.fargate.id]
    assign_public_ip               = false
    load_balancer_target_group_arn = aws_lb_target_group.this.arn
  }
  task_definition = {
    name           = "${local.aws_prefix_name}"
    container_name = "backend"
    container_port = 3000
    cpu            = 512
    memory         = 1024
  }
  environment_variables = [
    {
      name  = "NODE_ENV",
      value = "production"
    },
    {
      name  = "DATABASE_URL",
      value = "${module.rds_aurora.rds_aurora.connection_secret_string_arn}:connectionString::"
    }
  ]
  tags = {
    Environment = var.environment
  }
}

resource "github_actions_secret" "secrets" {
  for_each        = local.github_actions_secrets
  repository      = var.github_connection.repo_name
  secret_name     = each.value.secret_name
  plaintext_value = each.value.value
}