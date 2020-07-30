# Shared resources for the AWS account
# Used to get the VPC ID & subnet IDs that have been allocated for us
# Need the VPC ID
data "terraform_remote_state" "account_resources" {
  backend = "s3"

  config = {
    bucket = var.account_resources_state_bucket
    key    = var.account_resources_state_file
    region = var.account_resources_state_region
  }
}

# For the listener ARN
data "terraform_remote_state" "alb_listener" {
  backend = "s3"

  config = {
    bucket = var.alb_state_bucket
    key    = var.alb_state_file
    region = var.alb_state_region
  }
}

data "terraform_remote_state" "ecr" {
  backend = "s3"

  config = {
    bucket = var.ecr_state_bucket
    key    = var.ecr_state_file
    region = var.ecr_state_region
  }
}
