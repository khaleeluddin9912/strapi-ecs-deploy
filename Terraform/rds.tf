resource "random_password" "db_password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "aws_security_group" "rds_sg" {
  name   = "khaleel-rds-sg"
  vpc_id = data.aws_vpc.default.id
  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs_sg.id]
  }
  egress { 
    from_port   = 0 
    to_port     = 0 
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_db_instance" "strapi_db" {
  identifier          = "khaleel-strapi-db"
  engine              = "postgres"
  engine_version      = "16"
  instance_class      = var.db_instance_class
  allocated_storage   = 20

  db_name  = var.db_name
  username = var.db_username
  password = random_password.db_password.result

  vpc_security_group_ids = [aws_security_group.rds_sg.id]

  skip_final_snapshot = true
  publicly_accessible = false
}