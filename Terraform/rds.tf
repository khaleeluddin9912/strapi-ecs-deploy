#################################
# 1. RDS Security Group
#################################
resource "aws_security_group" "rds_sg" {
  name        = "khaleel-rds-sg"
  description = "Security group for RDS PostgreSQL"
  vpc_id      = data.aws_vpc.default.id

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

  tags = {
    Name = "khaleel-rds-sg"
  }
}

#################################
# 2. RDS PostgreSQL Instance
#################################
resource "aws_db_instance" "strapi_db" {
  identifier              = "khaleel-strapi-db"
  engine                  = "postgres"
  engine_version          = "16"
  instance_class          = "db.t3.micro"
  allocated_storage       = 20
  storage_type            = "gp3"

  db_name  = "strapidb"
  username = "strapiadmin"
  password = random_password.db_password.result

  # ✅ USE DEFAULT SUBNET GROUP (NO CONFLICT)
  db_subnet_group_name = "default"

  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  publicly_accessible   = true

  skip_final_snapshot     = true
  backup_retention_period = 7
  backup_window           = "03:00-04:00"
  maintenance_window      = "sun:04:00-sun:05:00"

  tags = {
    Name = "khaleel-strapi-db"
  }
}

#################################
# 3. Random Password for RDS
#################################
resource "random_password" "db_password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}