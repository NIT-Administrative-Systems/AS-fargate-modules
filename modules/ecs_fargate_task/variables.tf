variable "env" {}
variable "task_name" {}
variable "region" {}

# Fargate
variable "fargate_cpu" {
    default = 256
}
variable "fargate_memory" {
    default = 512
}
variable "task_iam_policy" {
    default = null # mark as unset if there is none provided
}
variable "container_env_variables" {
    type = map(string)
    default = {}
}
variable "container_secrets" {
    type = list(string)
    default = []
}

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
variable "ecr_image_tag" {
    default = "latest"
}