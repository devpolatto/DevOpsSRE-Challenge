resource "random_password" "master" {
  length  = 20
  special = false
}

resource "aws_secretsmanager_secret" "master" {
  name                    = var.secret.secret_name
  description             = "Master password for Aurora Serverless v2"
  recovery_window_in_days = var.secret.recovery_window_in_days
}

resource "aws_secretsmanager_secret_version" "master" {
  secret_id     = aws_secretsmanager_secret.master.id
  secret_string = random_password.master.result
}

resource "aws_rds_cluster" "this" {
  cluster_identifier  = var.aurora.name
  engine              = var.aurora.engine
  engine_mode         = var.aurora.engine_mode
  engine_version      = var.aurora.engine_version
  database_name       = var.aurora.database_name
  master_username     = var.aurora.master_username
  master_password     = random_password.master.result
  skip_final_snapshot = true
  deletion_protection = false

  serverlessv2_scaling_configuration {
    min_capacity = 0.5
    max_capacity = 8.0
  }

  db_subnet_group_name   = var.network.db_subnet_group_name
  vpc_security_group_ids = var.network.vpc_security_group_ids

  storage_encrypted = var.aurora.storage_encrypted
  kms_key_id        = var.aurora.kms_key_id

  tags = merge(
    var.tags,
    {
      Name = var.aurora.name
    }
  )
}

resource "aws_rds_cluster_instance" "writer" {
  count              = var.write_cluster_instence.enabled ? 1 : 0
  identifier         = "${var.aurora.name}-writer"
  cluster_identifier = aws_rds_cluster.this.id
  instance_class     = var.write_cluster_instence.instance_class
  engine             = var.aurora.engine
  engine_version     = var.aurora.engine_version

  performance_insights_enabled = true

  tags = merge(
    var.tags,
    {
      Name = var.aurora.name
    }
  )
}

resource "aws_rds_cluster_instance" "reader" {
  count              = var.reader_cluster_instence.enabled ? 1 : 0
  identifier         = "${var.aurora.name}-reader-${count.index + 1}"
  cluster_identifier = aws_rds_cluster.this.id
  instance_class     = var.reader_cluster_instence.instance_class
  engine             = var.aurora.engine
  engine_version     = var.aurora.engine_version
  tags = merge(
    var.tags,
    {
      Name = var.aurora.name
    }
  )
}