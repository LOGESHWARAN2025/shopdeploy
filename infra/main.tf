terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# ============================
# EXISTING VPC
# ============================
data "aws_vpc" "existing" {
  id = "vpc-05e383a9c12881652"
}

# ============================
# EXISTING SUBNET (ONLY ONE)
# ============================
data "aws_subnet" "existing" {
  id = "subnet-00480deb4c5bee56d"
}

# ============================
# EXISTING SECURITY GROUP
# ============================
data "aws_security_group" "ecs_sg" {
  id = "sg-06bee0aa7d646ca59"
}

# ============================
# ECS CLUSTER
# ============================
resource "aws_ecs_cluster" "this" {
  name = "shopdeploy-cluster"
}

# ============================
# IAM ROLE (ECS EXECUTION)
# ============================
resource "aws_iam_role" "ecs_task_execution" {
  name = "ecsTaskExecutionRole-shopdeploy"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Principal = { Service = "ecs-tasks.amazonaws.com" },
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_exec_policy" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# ============================
# CLOUDWATCH LOG GROUP
# ============================
resource "aws_cloudwatch_log_group" "api" {
  name              = "/ecs/shopdeploy-api"
  retention_in_days = 7
}

# ============================
# TASK DEFINITION
# ============================
resource "aws_ecs_task_definition" "api" {
  family                   = "shopdeploy-api"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn

  container_definitions = jsonencode([
    {
      name      = "api"
      image     = var.backend_image
      essential = true

      portMappings = [{
        containerPort = var.app_port
        protocol      = "tcp"
      }]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.api.name
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
}

# ============================
# ECS SERVICE (NO ALB)
# ============================
resource "aws_ecs_service" "api" {
  name            = "shopdeploy-api-service"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.api.arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets = [data.aws_subnet.existing.id]
    security_groups = [data.aws_security_group.ecs_sg.id]
    assign_public_ip = true
  }
}