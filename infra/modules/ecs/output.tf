output "ecs_cluster" {
  value = {
    id   = aws_ecs_cluster.this.id
    arn  = aws_ecs_cluster.this.arn
    name = aws_ecs_cluster.this.name
  }
}

output "ecs_task_definition" {
  value = {
    arn      = aws_ecs_task_definition.this.arn
    family   = aws_ecs_task_definition.this.family
    revision = aws_ecs_task_definition.this.revision
  }
}