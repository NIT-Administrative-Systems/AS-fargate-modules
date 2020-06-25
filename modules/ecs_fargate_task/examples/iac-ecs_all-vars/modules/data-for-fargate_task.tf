# Shared resources for the AWS account
# Used to get the VPC ID & subnet IDs that have been allocated for us
data "terraform_remote_state" "shared_resources" {
  backend = "s3"

  config = {
    bucket = var.account_resources_state_bucket
    key    = var.account_resources_state_file
    region = var.account_resources_state_region
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

# Policy document for the role to be assumed by the ECS Task itself while running
data "aws_iam_policy_document" "example_ecs_task_policy" {
    statement {
        actions = [
            "s3:put"
        ]

        resources = [
            aws_s3_bucket.example.arn
        ]
    }
}