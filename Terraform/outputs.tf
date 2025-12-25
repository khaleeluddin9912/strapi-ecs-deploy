output "alb_dns_name" {
  value = aws_lb.strapi_alb.dns_name
  description = "ALB DNS Name"
}

output "ecr_repository_url" {
  value       = data.aws_ecr_repository.khaleel_strapi_app.repository_url
  description = "ECR Repository URL"
}

# ECS Cluster Output
output "ecs_cluster_name" {
  value       = aws_ecs_cluster.khaleel_strapi_cluster.name
  description = "ECS Cluster Name"
}

# ECS Service Output
output "ecs_service_name" {
  value       = aws_ecs_service.khaleel_strapi_service.name
  description = "ECS Service Name"
}

# CodeDeploy Outputs – only if they exist, otherwise comment out for now
# output "codedeploy_app_name" {
#   value       = aws_codedeploy_app.khaleel_strapi_app.name
#   description = "CodeDeploy Application Name"
# }

# output "codedeploy_deployment_group" {
#   value       = aws_codedeploy_deployment_group.strapi_dg.deployment_group_name
#   description = "CodeDeploy Deployment Group"
# }
