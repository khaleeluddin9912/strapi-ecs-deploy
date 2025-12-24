#################################
# 1. ECR Repository
#################################
resource "aws_ecr_repository" "khaleel_strapi_app" {
  name = "khaleel-strapi-app"
  
  # Mutable allows overwriting 'latest' tag (better for CI/CD)
  image_tag_mutability = "MUTABLE"
  
  # Enable image scanning on push
  image_scanning_configuration {
    scan_on_push = true
  }
  
  # Force delete for cleanup
  force_delete = true
  
  tags = {
    Name = "khaleel-strapi-ecr"
  }
}

#################################
# 2. CloudWatch Log Group
#################################
resource "aws_cloudwatch_log_group" "khaleel_strapi_logs" {
  name              = "/ecs/khaleel-strapi-app"
  retention_in_days = 7
  
  tags = {
    Name = "khaleel-strapi-logs"
  }
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
  
  configuration {
    execute_command_configuration {
      logging = "DEFAULT"
    }
  }
  
  tags = {
    Name = "khaleel-strapi-cluster"
  }
}

#################################
# 4. ECS Task Definition (Updated by GitHub Actions)
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
    image     = "301782007642.dkr.ecr.ap-south-1.amazonaws.com/khaleel-strapi-app:latest"
    essential = true
    cpu       = 256
    memory    = 512

    portMappings = [{
      containerPort = 1337
      hostPort      = 1337
      protocol      = "tcp"
    }]

    # Health check for GitHub Actions and CodeDeploy
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
      { name = "DATABASE_CLIENT", value = "postgres" }
    ]

    # Store database config in environment (GitHub Actions will update)
    secrets = [
      {
        name      = "DATABASE_HOST"
        valueFrom = aws_ssm_parameter.database_host.arn
      },
      {
        name      = "DATABASE_PORT"
        valueFrom = aws_ssm_parameter.database_port.arn
      },
      {
        name      = "DATABASE_NAME"
        valueFrom = aws_ssm_parameter.database_name.arn
      },
      {
        name      = "DATABASE_USERNAME"
        valueFrom = aws_ssm_parameter.database_username.arn
      },
      {
        name      = "DATABASE_PASSWORD"
        valueFrom = aws_ssm_parameter.database_password.arn
      }
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
  
  tags = {
    Name = "khaleel-strapi-task"
  }
  
  depends_on = [
    aws_cloudwatch_log_group.khaleel_strapi_logs,
    aws_ecr_repository.khaleel_strapi_app
  ]
}

#################################
# 5. ECS Service (Configured for CodeDeploy Blue/Green)
#################################
resource "aws_ecs_service" "khaleel_strapi_service" {
  name            = "khaleel-strapi-service"
  cluster         = aws_ecs_cluster.khaleel_strapi_cluster.id
  task_definition = aws_ecs_task_definition.khaleel_strapi_task.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  # ✅ CRITICAL FOR TASK 11: Enable CodeDeploy for Blue/Green
  deployment_controller {
    type = "CODE_DEPLOY"
  }

  # Health check grace period for container startup
  health_check_grace_period_seconds = 120
  
  # Enable for debugging
  enable_execute_command  = true
  
  # Propagate tags to tasks
  propagate_tags = "SERVICE"

  network_configuration {
    subnets          = data.aws_subnets.default.ids
    security_groups  = [aws_security_group.ecs_sg.id]
    assign_public_ip = true
  }

  # ✅ Initial load balancer (Blue target group)
  load_balancer {
    target_group_arn = aws_lb_target_group.strapi_blue.arn
    container_name   = "khaleel-strapi-container"
    container_port   = 1337
  }

  # ✅ CRITICAL: Allow CodeDeploy to manage these during deployment
  lifecycle {
    ignore_changes = [
      task_definition,    # Updated by GitHub Actions
      load_balancer       # Managed by CodeDeploy during Blue/Green
    ]
  }

  depends_on = [
    aws_lb_target_group.strapi_blue,
    aws_lb_target_group.strapi_green,
    aws_lb_listener.http
  ]
  
  tags = {
    Name = "khaleel-strapi-service"
  }
}