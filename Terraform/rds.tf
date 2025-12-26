#################################
# RDS for Strapi
#################################

# Generate random password if you don't want to use a fixed one
resource "random_password" "db_password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

# RDS Security Group
resource "aws_security_group" "rds_sg" {
  name   = "khaleel-rds-sg"
  vpc_id = data.aws_vpc.default.id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs_sg.id] # Allow ECS
  }

  egress { 
    from_port   = 0 
    to_port     = 0 
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# RDS Parameter Group (disable SSL for testing)
resource "aws_db_parameter_group" "strapi_pg" {
  name        = "khaleel-strapi-pg"
  family      = "postgres16"
  description = "Parameter group for Strapi RDS DB"

  parameter {
    name  = "rds.force_ssl"
    value = "0"
  }
}

# RDS Database
resource "aws_db_instance" "strapi_db" {
  identifier          = "khaleel-strapi-db"
  engine              = "postgres"
  engine_version      = "16"
  instance_class      = var.db_instance_class
  allocated_storage   = 20

  db_name  = var.db_name
  username = var.db_username

  # Use random password or override with your secret
  password = var.db_password != "" ? var.db_password : random_password.db_password.result

  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  parameter_group_name   = aws_db_parameter_group.strapi_pg.name

  skip_final_snapshot    = true
  publicly_accessible    = false
}
