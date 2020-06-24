# for cloudwatch events to execute the ecs task
data "aws_iam_policy_document" "cw_execution_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }
  }
}

# semes like tf bug - need the depends_on to force it to redo the document when the task definition is updated
# the policy document isn't updating even though it should bc the ARN includes the revision
# so event role doesn't have the permissions to run the latest task definition

data "aws_iam_policy_document" "cw_role_policy" {
  depends_on = [aws_ecs_task_definition.main]

  statement {
    actions = [
      "ecs:RunTask",
    ]

    resources = [aws_ecs_task_definition.main.arn]

    condition {
      test     = "ArnLike"
      variable = "ecs:cluster"

      values = [
          aws_ecs_cluster.main.arn
      ]
    }
  }

  statement {
    actions = [
      "iam:PassRole",
    ]

    resources = [
      aws_iam_role.ecs_execution_role.arn,
      aws_iam_role.ecs_task_role.arn
    ]

    condition {
      test     = "StringLike"
      variable = "iam:PassedToService"

      values = [
        "ecs-tasks.amazonaws.com"
      ]
    }
  }
}

resource "aws_iam_role" "cw_event_execution_role" {
  name                  = "${var.task_name}-cw-event-role-${var.env}"
  assume_role_policy    = data.aws_iam_policy_document.cw_execution_assume_role_policy.json
  description           = "CW Execution Role for ${var.task_name} ECS"
  tags                  = local.tags
}

resource "aws_iam_role_policy" "cw_role_policy" {
  name   = "${var.task_name}-cw-event-role-policy-${var.env}"
  role   = aws_iam_role.cw_event_execution_role.id
  policy = data.aws_iam_policy_document.cw_role_policy.json
}
