data "aws_ecr_repository" "khaleel_strapi_app" {
  name = "khaleel-strapi-app"
}

resource "aws_ecs_cluster" "khaleel_strapi_cluster" {
  name = "khaleel-strapi-cluster"
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

resource "aws_ecs_task_definition" "khaleel_strapi_task" {
  family                   = "khaleel-strapi-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "512"
  memory                   = "1024"

  execution_role_arn = data.aws_iam_role.ecs_execution.arn
  task_role_arn      = data.aws_iam_role.ecs_execution.arn

  container_definitions = templatefile("${path.module}/.aws/task-definition.json", {
    IMAGE_URI        = var.image_uri
    DATABASE_HOST    = aws_db_instance.strapi_db.address
    DATABASE_PASS    = random_password.db_password.result
    APP_KEYS         = "REPLACE_WITH_REAL_APP_KEYS"
    API_TOKEN_SALT   = "REPLACE_WITH_REAL_API_TOKEN"
    ADMIN_JWT_SECRET = "REPLACE_WITH_REAL_ADMIN_JWT"
    JWT_SECRET       = "REPLACE_WITH_REAL_JWT_SECRET"
  })
}

resource "aws_ecs_service" "khaleel_strapi_service" {
  name            = "khaleel-strapi-service"
  cluster         = aws_ecs_cluster.khaleel_strapi_cluster.id
  task_definition = aws_ecs_task_definition.khaleel_strapi_task.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  deployment_controller { type = "CODE_DEPLOY" }

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

  lifecycle { ignore_changes = [task_definition, load_balancer] }
}
