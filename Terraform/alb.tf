# Application Load Balancer
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
  
  depends_on = [aws_security_group.alb_sg]
}

# Target Group - Blue (for current deployment)
resource "aws_lb_target_group" "strapi_blue" {
  name        = "khaleel-strapi-blue-tg"
  port        = 1337
  protocol    = "HTTP"
  vpc_id      = data.aws_vpc.default.id
  target_type = "ip"
  
  health_check {
    enabled             = true
    interval            = 30
    path                = "/"
    protocol            = "HTTP"
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200-399"
  }
  
  stickiness {
    enabled = false
    type    = "lb_cookie"
  }
  
  tags = {
    Name = "khaleel-blue-tg"
  }
  
  depends_on = [aws_lb.strapi_alb]
}

# Target Group - Green (for new deployment)
resource "aws_lb_target_group" "strapi_green" {
  name        = "khaleel-strapi-green-tg"
  port        = 1337
  protocol    = "HTTP"
  vpc_id      = data.aws_vpc.default.id
  target_type = "ip"
  
  health_check {
    enabled             = true
    interval            = 30
    path                = "/"
    protocol            = "HTTP"
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200-399"
  }
  
  stickiness {
    enabled = false
    type    = "lb_cookie"
  }
  
  tags = {
    Name = "khaleel-green-tg"
  }
  
  depends_on = [aws_lb.strapi_alb]
}

# HTTP Listener (for Blue/Green)
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
  
  depends_on = [
    aws_lb_target_group.strapi_blue,
    aws_lb_target_group.strapi_green
  ]
}

# S3 Bucket for ALB Logs (using your bucket-mku)
resource "aws_s3_bucket" "alb_logs" {
  bucket = "bucket-mku"
  
  tags = {
    Name = "khaleel-alb-logs"
  }
}

resource "aws_s3_bucket_acl" "alb_logs_acl" {
  bucket = aws_s3_bucket.alb_logs.id
  acl    = "private"
}