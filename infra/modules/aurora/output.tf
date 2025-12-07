output "rds_aurora" {
  value = {
    cluster_endpoint         = aws_rds_cluster.this.endpoint
    reader_endpoint          = aws_rds_cluster.this.reader_endpoint
    writer_instance_endpoint = var.write_cluster_instence.enabled ? aws_rds_cluster_instance.writer[0].endpoint : null
    reader_instance_endpoint = var.reader_cluster_instence.enabled ? aws_rds_cluster_instance.reader[0].endpoint : null
    port                     = aws_rds_cluster.this.port
    secret_name              = aws_secretsmanager_secret.master.name
    secret_arn               = aws_secretsmanager_secret.master.arn
  }
}
