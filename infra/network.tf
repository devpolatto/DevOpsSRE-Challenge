resource "aws_security_group" "aurora" {
  name        = "${local.aws_prefix_name}-aurora-sg"
  description = "Allow inbound from ECS Fargate"
  vpc_id      = module.vpc.vpc.id

  ingress {
    description     = "PostgreSQL from Fargate"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.fargate.id]
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

resource "aws_security_group" "alb" {
  name        = "${local.aws_prefix_name}-alb-sg"
  description = "Allow HTTPS inbound"
  vpc_id      = module.vpc.vpc.id

  ingress {
    description = "HTTPS from anywhere"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP (redirect to HTTPS)"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${local.aws_prefix_name}-alb-sg"
  }
}

resource "aws_lb" "this" {
  name               = "${local.aws_prefix_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = module.vpc.public_subnets.ids

  enable_deletion_protection = false
  enable_http2               = true

  tags = {
    Name = "${local.aws_prefix_name}-alb"
  }
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.this.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }
}

resource "aws_lb_listener" "http_redirect" {
  load_balancer_arn = aws_lb.this.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_wafv2_web_acl" "this" {
  name  = "${local.aws_prefix_name}-alb-waf"
  scope = "REGIONAL"

  default_action {
    allow {}
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "${local.aws_prefix_name}-waf"
    sampled_requests_enabled   = true
  }

  rule {
    name     = "RateLimit2000"
    priority = 20

    action {
      block {}
    }

    statement {
      rate_based_statement {
        limit              = 2000
        aggregate_key_type = "IP"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "RateLimit2000"
      sampled_requests_enabled   = true
    }
  }
}

resource "aws_wafv2_web_acl_association" "this" {
  resource_arn = aws_lb.this.arn
  web_acl_arn  = aws_wafv2_web_acl.this.arn
}

resource "aws_security_group" "fargate" {
  name        = "${local.aws_prefix_name}-fargate-sg"
  description = "Allow inbound from ALB only"
  vpc_id      = module.vpc.vpc.id

  ingress {
    description     = "From ALB"
    from_port       = 3000
    to_port         = 3000
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${local.aws_prefix_name}-fargate-sg"
  }
}

resource "aws_lb_target_group" "this" {
  name        = "${local.aws_prefix_name}-ecs-tg"
  port        = 3000
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = module.vpc.vpc.id

  health_check {
    enabled             = true
    path                = "/health"
    interval            = 30
    timeout             = 10
    healthy_threshold   = 2
    unhealthy_threshold = 5
    matcher             = "200"
  }
}