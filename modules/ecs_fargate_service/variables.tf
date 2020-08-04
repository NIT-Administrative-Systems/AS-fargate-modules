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
variable "alb_security_group_id" {}
variable "task_listening_port" {
    type = number
    default = 8080
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

# ALB
variable "deregistration_delay" {
    type = number
    default = 300
}
variable "alb_listener_arn" {}
variable "hostnames" {
    type = list(string)
}

# Auto Scaling
variable "min_capacity" {}
variable "max_capacity" {}
variable "cpu_target" {
    type = number
    default = 75
}
variable "memory_target" {
    type = number
    default = 75
}
variable "cpu_scalein_cooldown" {
    type = number
    default = 180 # reduce costs by allowing the group to scale in faster than aws 300 default
}
variable "cpu_scaleout_cooldown" {
    type = number
    default = 180
}
variable "memory_scalein_cooldown" {
    type = number
    default = 180 # reduce costs by allowing the group to scale in faster than aws 300 default
}
variable "memory_scaleout_cooldown" {
    type = number
    default = 180
}

# LB Health Check
variable "hc_healthy_threshold" {
    type = number
    default = 4
}
variable "hc_unhealthy_threshold" {
    type = number
    default = 2
}
variable "hc_timeout" {
    type = number
    default = 15
}
variable "hc_interval" {
    type = number
    default = 60
}
variable "hc_path" {
    type = string
    default = "/healthcheck"
}
variable "hc_matcher" {
    type = string
    default = "200"
}
variable "hc_grace_period" {
    type = number
    default = 30
}

# ECS Deploy
variable "ecs_deploy_min_healthy_perc" {
 type = number
 default = 100
}
variable "ecs_deploy_max_perc" {
 type = number
 default = 200
}