# role for the container - get ecr image etc.
data "aws_iam_policy_document" "ecs_execution_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_execution_role" {
  name                  = "${var.task_name}-ecs-execution-role-${var.env}"
  assume_role_policy    = data.aws_iam_policy_document.ecs_execution_assume_role_policy.json
  description           = "ECS Execution Role for NodeJS POC - ${var.env}"
  tags                  = local.tags
}

data "aws_iam_policy_document" "ecs_execution_container_policy" {
    statement {
        actions = [
            "ecr:GetAuthorizationToken",
            "ecr:BatchCheckLayerAvailability",
            "ecr:GetDownloadUrlForLayer",
            "ecr:BatchGetImage",
        ]

        resources = [
            var.ecr_repository_arn
        ]
    }

    statement {
        actions = [
            "ecr:GetAuthorizationToken",
        ]

        resources = [
            "*"
        ]
    }

    statement {
        actions = [
            "logs:*"
        ]

        resources = [
            "*"
        ]
    }
}

resource "aws_iam_role_policy" "ecs_execution_role_policy" {
    name    = "${var.task_name}-ecs-execution-role-policy-${var.env}"
    role    = aws_iam_role.ecs_execution_role.id
    policy  = data.aws_iam_policy_document.ecs_execution_container_policy.json
}

# role assumed by the ECS Task itself while running
# data "aws_iam_role" "ecs_task_role" {
#   name = "${var.fc_iam_role}-${var.env}"
# }

data "aws_iam_policy_document" "task_policy" {
    statement {
        actions = [
            # kms decrypt
            # ssm get 
            # dynamodb
            # s3
            # etc.
        ]

        resources = [
            # kms key, ssm, dynamo, s3, etc. 
        ]
    }
}

resource "aws_iam_role_policy" "task_role_policy" {
    name    = "${var.task_name}-task-role-policy-${var.env}"
    role    = aws_iam_role.ecs_task_role.id
    policy  = data.aws_iam_policy_document.ecs_execution_container_policy.json
}

data "aws_iam_policy_document" "task_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_task_role" {
  name                  = "${var.task_name}-task-role-${var.env}"
  assume_role_policy    = data.aws_iam_policy_document.task_assume_role_policy.json
  description           = "${var.task_name} - ECS Task Role - ${var.env}"
  tags                  = local.tags
}