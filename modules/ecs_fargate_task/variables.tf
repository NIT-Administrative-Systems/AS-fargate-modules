variable "env" {}
variable "task_name" {}
variable "region" {}

# Fargate
variable "fargate_cpu" {}
variable "fargate_memory" {}

# Fargate Networking
variable "vpc_id" {}
variable "subnet_name_tags" {
    type = list(string)
}

# CW Rules
variable "cw_status" {}
variable "is_dst" {}
variable "dst_on_schedule" {}
variable "dst_off_schedule" {}

# ECR
variable "ecr_repository_url"{}
variable "ecr_repository_arn" {}
variable "ecr_image_tag" {}