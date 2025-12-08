resource "aws_ecr_repository" "this" {
  name                 = var.repository.name
  image_tag_mutability = var.repository.image_tag_mutability
  image_scanning_configuration {
    scan_on_push = var.repository.scan_on_push
  }

  encryption_configuration {
    encryption_type = "AES256"
  }

  tags = merge(
    {
      "Name" = var.repository.name
    },
    var.tags,
  )
}

resource "aws_ecr_lifecycle_policy" "this" {
  repository = aws_ecr_repository.this.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Manter apenas as últimas 10 imagens tagged"
        selection = {
          tagStatus     = "tagged"
          tagPrefixList = ["prod", "latest"]
          countType     = "imageCountMoreThan"
          countNumber   = 10
        }
        action = {
          type = "expire"
        }
      },
      {
        rulePriority = 2
        description  = "Remover imagens untagged após 1 dia"
        selection = {
          tagStatus   = "untagged"
          countType   = "sinceImagePushed"
          countUnit   = "days"
          countNumber = 1
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}