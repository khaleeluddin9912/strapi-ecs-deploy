variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-south-1"
}

variable "image_uri" {
  description = "Full ECR image URI with tag"
  type        = string
  default     = "301782007642.dkr.ecr.ap-south-1.amazonaws.com/khaleel-strapi-app:latest"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "production"
}

variable "strapi_port" {
  description = "Strapi application port"
  type        = number
  default     = 1337
}

variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "ecs_task_cpu" {
  description = "ECS task CPU units"
  type        = string
  default     = "512"
}

variable "ecs_task_memory" {
  description = "ECS task memory"
  type        = string
  default     = "1024"
}