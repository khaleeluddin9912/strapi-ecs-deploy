#################################
# 1. CodeDeploy Application (for Blue/Green)
#################################
resource "aws_codedeploy_app" "khaleel_strapi_app" {
  compute_platform = "ECS"
  name             = "khaleel-strapi-app"
  
  tags = {
    Name = "khaleel-codedeploy-app"
  }
}

#################################
# 2. CodeDeploy Deployment Group (Blue/Green)
#################################
resource "aws_codedeploy_deployment_group" "strapi_dg" {
  app_name               = aws_codedeploy_app.khaleel_strapi_app.name
  deployment_group_name  = "khaleel-strapi-dg"
  service_role_arn       = data.aws_iam_role.codedeploy_role.arn
  
  # ✅ Auto rollback on failure (Task 11 requirement)
  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE"]
  }
  
  # ✅ Blue/Green deployment configuration
  deployment_style {
    deployment_option = "WITH_TRAFFIC_CONTROL"
    deployment_type   = "BLUE_GREEN"
  }
  
  blue_green_deployment_config {
    deployment_ready_option {
      action_on_timeout    = "CONTINUE_DEPLOYMENT"
      wait_time_in_minutes = 0
    }
    
    terminate_blue_instances_on_deployment_success {
      action                           = "TERMINATE"
      termination_wait_time_in_minutes = 5
    }
  }
  
  # ✅ ECS service to deploy
  ecs_service {
    cluster_name = aws_ecs_cluster.khaleel_strapi_cluster.name
    service_name = aws_ecs_service.khaleel_strapi_service.name
  }
  
  # ✅ Load balancer configuration for Blue/Green
  load_balancer_info {
    target_group_pair_info {
      prod_traffic_route {
        listener_arns = [aws_lb_listener.http.arn]
      }
      
      target_group {
        name = aws_lb_target_group.strapi_blue.name
      }
      
      target_group {
        name = aws_lb_target_group.strapi_green.name
      }
    }
  }
  
  tags = {
    Name = "khaleel-codedeploy-dg"
  }
  
  depends_on = [
    aws_ecs_service.khaleel_strapi_service,
    aws_lb_target_group.strapi_blue,
    aws_lb_target_group.strapi_green,
    aws_lb_listener.http
  ]
}