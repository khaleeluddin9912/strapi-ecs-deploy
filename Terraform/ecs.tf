#################################
# 1. Use existing ECR Repository
#################################
data "aws_ecr_repository" "khaleel_strapi_app" {
  name = "khaleel-strapi-app"
}

#################################
# 2. CloudWatch Log Group
#################################
resource "aws_cloudwatch_log_group" "khaleel_strapi_logs" {
  name              = "/ecs/khaleel-strapi-app"
  retention_in_days = 7
}

#################################
# 3. ECS Cluster
#################################
resource "aws_ecs_cluster" "khaleel_strapi_cluster" {
  name = "khaleel-strapi-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

#################################
# 4. ECS Task Definition (Dynamic Image)
#################################
resource "aws_ecs_task_definition" "khaleel_strapi_task" {
  family                   = "khaleel-strapi-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "512"
  memory                   = "1024"
  execution_role_arn       = data.aws_iam_role.ecs_execution.arn
  task_role_arn            = data.aws_iam_role.ecs_execution.arn

  container_definitions = jsonencode([{
    name      = "khaleel-strapi-container"
    image     = var.image_uri  # <- dynamic from GitHub Actions
    essential = true
    cpu       = 256
    memory    = 512

    portMappings = [{
      containerPort = 1337
      hostPort      = 1337
      protocol      = "tcp"
    }]

    healthCheck = {
      command     = ["CMD-SHELL", "curl -f http://localhost:1337 || exit 1"]
      interval    = 30
      timeout     = 5
      retries     = 3
      startPeriod = 60
    }

    environment = [
      { name = "NODE_ENV", value = "production" },
      { name = "HOST", value = "0.0.0.0" },
      { name = "PORT", value = "1337" },
      { name = "DATABASE_CLIENT", value = "postgres" },
      { name = "DATABASE_HOST", value = "RDS-ENDPOINT-HERE" },        # replace with actual RDS endpoint
      { name = "DATABASE_PORT", value = "5432" },
      { name = "DATABASE_NAME", value = "strapidb" },
      { name = "DATABASE_USERNAME", value = "strapiadmin" },
      { name = "DATABASE_PASSWORD", value = "YOUR-RDS-PASSWORD" }     # replace with actual password
    ]

    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = aws_cloudwatch_log_group.khaleel_strapi_logs.name
        awslogs-region        = "ap-south-1"
        awslogs-stream-prefix = "ecs"
      }
    }
  }])
}

#################################
# 5. ECS Service (Blue/Green)
#################################
resource "aws_ecs_service" "khaleel_strapi_service" {
  name            = "khaleel-strapi-service"
  cluster         = aws_ecs_cluster.khaleel_strapi_cluster.id
  task_definition = aws_ecs_task_definition.khaleel_strapi_task.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  deployment_controller {
    type = "CODE_DEPLOY"
  }

  health_check_grace_period_seconds = 120
  enable_execute_command            = true
  propagate_tags                    = "SERVICE"

  network_configuration {
    subnets          = data.aws_subnets.default.ids
    security_groups  = [aws_security_group.ecs_sg.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.strapi_blue.arn
    container_name   = "khaleel-strapi-container"
    container_port   = 1337
  }

  lifecycle {
    ignore_changes = [
      task_definition,
      load_balancer
    ]
  }

  depends_on = [
    aws_lb_target_group.strapi_blue,
    aws_lb_target_group.strapi_green,
    aws_lb_listener.http
  ]
}