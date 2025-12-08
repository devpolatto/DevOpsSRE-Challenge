output "repository" {
  value = {
    name           = aws_ecr_repository.this.name
    uri            = aws_ecr_repository.this.repository_url
    repository_arn = aws_ecr_repository.this.arn
    registry_id    = aws_ecr_repository.this.registry_id
  }
}