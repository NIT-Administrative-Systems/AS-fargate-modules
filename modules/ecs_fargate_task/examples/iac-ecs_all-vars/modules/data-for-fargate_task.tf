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
            "s3:putObject"
        ]

        resources = [
            aws_s3_bucket.example.arn,
            "${aws_s3_bucket.example.arn}/*"
        ]
    }
}

# Traffic to/from the ECS Cluster
resource "aws_security_group" "inbound_outbound" {
  name        = "${var.app_name}-Example-${var.environment}"
  description = "${var.app_name} ECS cluster inbound outbound traffic - ${var.environment}"
  vpc_id      = data.terraform_remote_state.shared_resources.outputs.vpc_id

  # outbound traffic for NAT Gateway and outside API calls
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # equivalent of ALL which is not allowed here
    cidr_blocks = ["0.0.0.0/0"]
  }

  # example
  ingress {
    from_port = 443
    to_port   = 443
    protocol  = "tcp"
    cidr_blocks = ["your.cidr.block.here/example"]
  }
}
