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
  description           = "${var.task_name} - ECS Execution Role - ${var.env}"
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

    statement {
        actions = [
            "ssm:GetParameters"
        ]
        
        resources = aws_ssm_parameter.secure_param[*].arn
    }

    statement {
        actions = [
            "kms:Decrypt"
        ]

        resources = [
            aws_kms_key.key.arn
        ]
    }
}

resource "aws_iam_role_policy" "ecs_execution_role_policy" {
    name    = "${var.task_name}-ecs-execution-role-policy-${var.env}"
    role    = aws_iam_role.ecs_execution_role.id
    policy  = data.aws_iam_policy_document.ecs_execution_container_policy.json
}
