resource "aws_security_group" "aurora" {
  name        = "${local.aws_prefix_name}-aurora-sg"
  description = "Allow inbound from ECS Fargate"
  vpc_id      = module.vpc.vpc.id

  ingress {
    description     = "PostgreSQL from Fargate"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [] # passar do ECS depois
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${local.aws_prefix_name}-aurora-sg"
  }
}

resource "aws_db_subnet_group" "this" {
  name       = "${lower(replace(local.aws_prefix_name, "-", ""))}aurora"
  subnet_ids = module.vpc.private_subnets.ids

  tags = {
    Name = "${local.aws_prefix_name}-aurora-subnet-group"
  }
}