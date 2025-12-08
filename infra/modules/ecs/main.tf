resource "aws_ecs_cluster" "this" {
  name = "${var.task_definition.name}-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = { Name = "${var.task_definition.name}-cluster" }
}

resource "aws_iam_role" "task" {
  name = "${var.task_definition.name}-ecs-task-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = { Service = "ecs-tasks.amazonaws.com" }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "task_ssm" {
  role       = aws_iam_role.task.name
  policy_arn = local.task_ssm_arn
}

resource "aws_iam_role_policy" "task_secrets" {
  name = "SecretsAccess"
  role = aws_iam_role.task.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["secretsmanager:GetSecretValue"]
        Resource = "*"
      }
    ]
  })
}

resource "aws_ecs_task_definition" "this" {
  family                   = "${var.task_definition.name}-backend"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"
  memory                   = "1024"
  execution_role_arn       = aws_iam_role.task.arn
  task_role_arn            = aws_iam_role.task.arn

  container_definitions = jsonencode([
    {
      name      = "backend"
      image     = "${var.ecr.repository_url}:latest"
      essential = true

      portMappings = [
        {
          containerPort = 3000
          protocol      = "tcp"
        }
      ]

      environment = var.environment_variables

      # secrets = var.secrets

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.this.name
          "awslogs-region"        = data.aws_region.current.name
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])

  tags = merge(
    {
      "Name" = "${var.task_definition.name}-backend-task"
    },
    var.tags,
  )
}

resource "aws_cloudwatch_log_group" "this" {
  name              = "/ecs/${var.task_definition.name}-backend"
  retention_in_days = 7
}

resource "aws_ecs_service" "this" {
  name            = "${var.task_definition.name}-service"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.this.arn
  desired_count   = 2
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.network.subnets
    security_groups  = var.network.security_groups
    assign_public_ip = var.network.assign_public_ip
  }

  load_balancer {
    target_group_arn = var.network.load_balancer_target_group_arn
    container_name   = var.task_definition.container_name
    container_port   = var.task_definition.container_port
  }

  deployment_minimum_healthy_percent = 50
  deployment_maximum_percent         = 200

  tags = merge(
    {
      "Name" = "${var.task_definition.name}-service"
    },
    var.tags,
  )
}