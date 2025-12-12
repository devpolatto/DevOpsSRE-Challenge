output "repository" {
  value = {
    name           = aws_ecr_repository.this[0].name
    uri            = aws_ecr_repository.this[0].repository_url
    repository_arn = aws_ecr_repository.this[0].arn
    registry_id    = aws_ecr_repository.this[0].registry_id
  }
}