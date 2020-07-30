variable "environment" {
  description = "Environment that this app is runnig for, e.g. dev/qa/prod"
}

variable "region" {
  default = "us-east-2"
}

variable "app_name" {
  default = "as-fargate-service-example"
}

variable "account_resources_state_bucket" {
  description = "State bucket for shared account resources"
}

variable "account_resources_state_file" {
  description = "State file for shared account resources"
}

variable "account_resources_state_region" {
  description = "State region for shared account resources"

  default = "us-east-2"
}

variable "alb_state_bucket" {
  description = "State bucket for account alb resources"
}

variable "alb_state_file" {
  description = "State file for account alb resources"
}

variable "alb_state_region" {
  description = "State region for account alb resources"

  default = "us-east-2"
}

variable "ecr_state_bucket" {
  description = "State bucket for ECR resources"
}

variable "ecr_state_file" {
  description = "State file for ECR resources"
}

variable "ecr_state_region" {
  description = "State region for ECR resources"

  default = "us-east-2"
}

