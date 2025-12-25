#################################
# AWS Region
#################################
variable "aws_region" {
  description = "AWS region for all resources"
  type        = string
  default     = "ap-south-1"
}

#################################
# ECS Image URI (Injected by GitHub Actions)
#################################
variable "image_uri" {
  description = "Full ECR image URI with tag"
  type        = string
  default     = "301782007642.dkr.ecr.ap-south-1.amazonaws.com/khaleel-strapi-app:dummy"
}

#################################
# Environment
#################################
variable "environment" {
  description = "Deployment environment name"
  type        = string
  default     = "production"
}

#################################
# Strapi Application Port
#################################
variable "strapi_port" {
  description = "Port on which Strapi runs inside the container"
  type        = number
  default     = 1337
}

#################################
# ECS Task Resources (Fargate)
#################################
variable "ecs_task_cpu" {
  description = "CPU units for ECS Fargate task"
  type        = number
  default     = 512
}

variable "ecs_task_memory" {
  description = "Memory (MiB) for ECS Fargate task"
  type        = number
  default     = 1024
}

#################################
# RDS Configuration (Used Elsewhere)
#################################
variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
}
