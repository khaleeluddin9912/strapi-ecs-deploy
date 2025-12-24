output "alb_dns_name" {
  description = "ALB DNS name (HTTP access)"
  value       = "http://${aws_lb.strapi_alb.dns_name}"
}

output "alb_dns_https" {
  description = "ALB DNS name (HTTPS - if configured)"
  value       = "https://${aws_lb.strapi_alb.dns_name}"
}

output "rds_endpoint" {
  description = "RDS endpoint for database connection"
  value       = aws_db_instance.strapi_db.endpoint
}

output "ecr_repository_url" {
  description = "ECR repository URL for Docker images"
  value       = aws_ecr_repository.khaleel_strapi_app.repository_url
}

output "ecs_cluster_name" {
  description = "ECS cluster name"
  value       = aws_ecs_cluster.khaleel_strapi_cluster.name
}

output "ecs_service_name" {
  description = "ECS service name"
  value       = aws_ecs_service.khaleel_strapi_service.name
}

output "codedeploy_app_name" {
  description = "CodeDeploy application name"
  value       = aws_codedeploy_app.khaleel_strapi_app.name
}

output "codedeploy_deployment_group" {
  description = "CodeDeploy deployment group name"
  value       = aws_codedeploy_deployment_group.strapi_dg.deployment_group_name
}

output "blue_target_group_name" {
  description = "Blue target group name"
  value       = aws_lb_target_group.strapi_blue.name
}

output "green_target_group_name" {
  description = "Green target group name"
  value       = aws_lb_target_group.strapi_green.name
}

output "database_credentials_ssm_path" {
  description = "SSM parameter paths for database credentials"
  value = {
    host     = "/khaleel/database/host"
    port     = "/khaleel/database/port"
    name     = "/khaleel/database/name"
    username = "/khaleel/database/username"
    password = "/khaleel/database/password"
  }
}