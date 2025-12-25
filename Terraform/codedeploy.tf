resource "aws_codedeploy_app" "khaleel_strapi_app" {
  name             = "khaleel-strapi-app"
  compute_platform = "ECS"
}

resource "aws_codedeploy_deployment_group" "strapi_dg" {
  app_name              = aws_codedeploy_app.khaleel_strapi_app.name
  deployment_group_name = "khaleel-strapi-dg"
  service_role_arn      = data.aws_iam_role.codedeploy_role.arn
  deployment_config_name = "CodeDeployDefault.ECSCanary10Percent5Minutes"

  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE"]
  }

  deployment_style {
    deployment_option = "WITH_TRAFFIC_CONTROL"
    deployment_type   = "BLUE_GREEN"
  }

  blue_green_deployment_config {
    deployment_ready_option { action_on_timeout = "CONTINUE_DEPLOYMENT" }
    terminate_blue_instances_on_deployment_success {
      action = "TERMINATE"
      termination_wait_time_in_minutes = 5
    }
  }

  ecs_service {
    cluster_name = aws_ecs_cluster.khaleel_strapi_cluster.name
    service_name = aws_ecs_service.khaleel_strapi_service.name
  }

  load_balancer_info {
    target_group_pair_info {
      prod_traffic_route { listener_arns = [aws_lb_listener.http.arn] }
      target_group { name = aws_lb_target_group.strapi_blue.name }
      target_group { name = aws_lb_target_group.strapi_green.name }
    }
  }

  depends_on = [aws_codedeploy_app.khaleel_strapi_app, aws_ecs_service.khaleel_strapi_service, aws_lb_listener.http]
}