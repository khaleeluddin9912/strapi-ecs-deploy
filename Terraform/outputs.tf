output "alb_dns_name" {
  description = "ALB DNS name to access Strapi"
  value       = aws_lb.strapi_alb.dns_name
}

output "ecr_repository_url" {
  description = "ECR Repository URL"
  value       = data.aws_ecr_repository.khaleel_strapi_app.repository_url
}

output "ecs_cluster_name" {
  description = "ECS Cluster Name"
  value       = aws_ecs_cluster.khaleel_strapi_cluster.name
}

output "ecs_service_name" {
  description = "ECS Service Name"
  value       = aws_ecs_service.khaleel_strapi_service.name
}

# NEW: Add these outputs
output "rds_endpoint" {
  description = "RDS endpoint for Strapi database"
  value       = aws_db_instance.strapi_db.endpoint
  sensitive   = true
}

output "database_name" {
  description = "Strapi database name"
  value       = aws_db_instance.strapi_db.db_name
}