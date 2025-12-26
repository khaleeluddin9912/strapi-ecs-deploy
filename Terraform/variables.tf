variable "aws_region" {
  description = "AWS region for all resources"
  type        = string
  default     = "ap-south-1"
}

variable "db_name" {
  description = "Strapi database name"
  type        = string
  default     = "strapidb"
}

variable "db_username" {
  description = "Strapi database username"
  type        = string
  default     = "strapiadmin"
}

variable "db_password" {
  description = "Strapi database password"
  type        = string
  default     = ""  
}

variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "production"
}

variable "strapi_port" {
  description = "Port for Strapi container"
  type        = number
  default     = 1337
}

variable "image_uri" {
  description = "Full ECR image URI with tag"
  type        = string
  default     = "301782007642.dkr.ecr.ap-south-1.amazonaws.com/khaleel-strapi-app:latest"
}
