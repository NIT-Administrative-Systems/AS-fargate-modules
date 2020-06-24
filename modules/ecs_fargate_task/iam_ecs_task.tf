# create a policy from the document passed in
resource "aws_iam_role_policy" "task_role_policy" {
    name    = "${var.task_name}-task-role-policy-${var.env}"
    role    = aws_iam_role.ecs_task_role.id
    policy  = var.task_iam_policy.json
}

# create another policy for the kms key and any ssm secrets created
data "aws_iam_policy_document" "task_secrets_policy" {
    statement {
        actions = [
            "kms:Decrypt"
        ]

        resources = [
            aws_kms_key.key.arn
        ]
    }

    statement {
        actions = [
            "ssm:GetParameter",
            "ssm:GetParameters"
        ]
        
        resources = aws_ssm_parameter.secure_param[*].arn
    }
}
resource "aws_iam_role_policy" "task_secrets_policy" {
    name    = "${var.task_name}-task-secrets-policy-${var.env}"
    role    = aws_iam_role.ecs_task_role.id
    policy  = data.aws_iam_policy_document.task_secrets_policy.json
}

# allow the task to assume the role
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