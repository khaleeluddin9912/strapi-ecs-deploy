output "alb_dns_name" {
  value = "http://${aws_lb.strapi_alb.dns_name}"
}

output "ecr_repository_url" {
  value = data.aws_ecr_repository.khaleel_strapi_app.repository_url
}

output "ecs_cluster_name" {
  value = aws_ecs_cluster.khaleel_strapi_cluster.name
}

output "ecs_service_name" {
  value = aws_ecs_service.khaleel_strapi_service.name
}

output "codedeploy_app_name" {
  value = aws_codedeploy_app.khaleel_strapi_app.name
}

output "codedeploy_deployment_group" {
  value = aws_codedeploy_deployment_group.strapi_dg.deployment_group_name
}