#################################
# ECS Configuration
#################################

# Existing ECR Repository
data "aws_ecr_repository" "khaleel_strapi_app" {
  name = "khaleel-strapi-app"
}

#################################
# CloudWatch Log Group (REQUIRED)
#################################
resource "aws_cloudwatch_log_group" "ecs_strapi" {
  name              = "/ecs/khaleel-strapi-app"
  retention_in_days = 7
}

#################################
# ECS Cluster
#################################
resource "aws_ecs_cluster" "khaleel_strapi_cluster" {
  name = "khaleel-strapi-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

#################################
# ECS Task Definition
#################################
resource "aws_ecs_task_definition" "khaleel_strapi_task" {
  family                   = "khaleel-strapi-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "512"
  memory                   = "1024"

  execution_role_arn = data.aws_iam_role.ecs_execution.arn
  task_role_arn      = data.aws_iam_role.ecs_execution.arn

  depends_on = [
    aws_cloudwatch_log_group.ecs_strapi
  ]

  container_definitions = jsonencode([
    {
      name      = "khaleel-strapi-container"
      image     = var.image_uri
      essential = true

      portMappings = [
        {
          containerPort = var.strapi_port
          protocol      = "tcp"
        }
      ]

      environment = [
        { name = "NODE_ENV", value = "production" },
        { name = "HOST", value = "0.0.0.0" },
        { name = "PORT", value = tostring(var.strapi_port) },
        { name = "DATABASE_HOST", value = aws_db_instance.strapi_db.address },
        { name = "DATABASE_PASSWORD", value = random_password.db_password.result },
        { name = "APP_KEYS", value = "REPLACE_WITH_REAL_APP_KEYS" },
        { name = "API_TOKEN_SALT", value = "REPLACE_WITH_REAL_API_TOKEN" },
        { name = "ADMIN_JWT_SECRET", value = "REPLACE_WITH_REAL_ADMIN_JWT" },
        { name = "JWT_SECRET", value = "REPLACE_WITH_REAL_JWT_SECRET" }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/khaleel-strapi-app"
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
}

#################################
# ECS Service (Blue/Green CodeDeploy)
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
    container_port   = var.strapi_port
  }

  lifecycle {
    ignore_changes = [
      task_definition,
      load_balancer
    ]
  }
}