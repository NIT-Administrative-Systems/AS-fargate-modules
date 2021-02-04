variable "env" {}
variable "task_name" {}
variable "region" {}

# Fargate Task
variable "task_cpu" {
    type = number
    default = 256
}
variable "task_memory" {
    type = number 
    default = 512
}
variable "aws_task_iam_policy_document" {
    default = null # mark as unset if there is none provided
}
variable "task_count" {
    type = number
    default = 1
}
variable "task_family" {
    type = string
    default = null # defaults to unset and will be generated in the task definition from other vars
}
# Container Definition
variable "container_env_variables" {
    type = list(object({
        name  = string
        value = string
    }))
    default = []
}
variable "container_secrets" {
    type = list(string)
    default = []
}
variable "container_port_mappings" {
    type = list(object({
        containerPort = number
        hostPort      = number
        protocol      = string
    }))
    default = []
}

# Task Networking
variable "vpc_id" {}
variable "subnet_ids" {
    type = list(string)
}
variable "assign_public_ip" {
    type = bool
    default = false
}
variable "aws_security_group" {
    default = null # mark as unset if there is none provided
}

# CW Rules
variable "cw_status" {
    type = bool # I think people could still set this as false if they don't want to use cw 
}
variable "cw_schedule" {
    default = null # optional - mark as unset if none provided 
}

# ECR
variable "ecr_repository_url"{}
variable "ecr_repository_arn" {}
variable "ecr_image_tag" {
    type = string
    default = "latest"
}

variable "tags" {
    type = map(string)
    default = {}
}