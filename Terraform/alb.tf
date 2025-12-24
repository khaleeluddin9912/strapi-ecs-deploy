#################################
# 1. Application Load Balancer
#################################
resource "aws_lb" "strapi_alb" {
  name               = "khaleel-strapi-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = data.aws_subnets.default.ids

  enable_deletion_protection = false

  tags = {
    Name = "khaleel-strapi-alb"
  }
}

#################################
# 2. Target Group - Blue
#################################
resource "aws_lb_target_group" "strapi_blue" {
  name        = "khaleel-strapi-blue-tg"
  port        = 1337
  protocol    = "HTTP"
  vpc_id      = data.aws_vpc.default.id
  target_type = "ip"

  health_check {
    enabled             = true
    interval            = 30
    path                = "/admin"
    protocol            = "HTTP"
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200-399"
  }

  tags = {
    Name = "khaleel-blue-tg"
  }
}

#################################
# 3. Target Group - Green
#################################
resource "aws_lb_target_group" "strapi_green" {
  name        = "khaleel-strapi-green-tg"
  port        = 1337
  protocol    = "HTTP"
  vpc_id      = data.aws_vpc.default.id
  target_type = "ip"

  health_check {
    enabled             = true
    interval            = 30
    path                = "/admin"
    protocol            = "HTTP"
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200-399"
  }

  tags = {
    Name = "khaleel-green-tg"
  }
}

#################################
# 4. HTTP Listener (Blue/Green)
#################################
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.strapi_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.strapi_blue.arn
  }

  tags = {
    Name = "khaleel-http-listener"
  }
}

#################################
# 5. S3 Bucket for ALB Logs
#################################
data "aws_s3_bucket" "alb_logs" {
  bucket = "bucket-mku"
}
