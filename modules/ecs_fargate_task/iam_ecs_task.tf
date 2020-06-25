# create a policy from the document passed in
resource "aws_iam_role_policy" "task_role_policy" {
    count = var.task_iam_policy != null ? 1 : 0 # only create if a policy document is provided 

    name    = "${local.task_short_name}-task-role-policy-${var.env}"
    role    = aws_iam_role.ecs_task_role.id
    policy  = var.task_iam_policy.json
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
  name                  = "${local.task_short_name}-task-role-${var.env}"
  assume_role_policy    = data.aws_iam_policy_document.task_assume_role_policy.json
  description           = "${local.task_short_name} - ECS Task Role - ${var.env}"
  tags                  = local.tags
}