resource "aws_cloudwatch_event_rule" "task_schedule" {
    count = var.cw_schedule != null ? 0 : 1 # only create if a cloudwatch schedule is provided as an input

    name                = "${local.task_short_name}-${var.env}"
    schedule_expression = var.cw_schedule
    is_enabled          = var.cw_status
    tags                = local.tags
}

resource "aws_cloudwatch_event_target" "ecs_scheduled_task" {
    count = var.cw_schedule != null ? 0 : 1 # only create if a cloudwatch schedule is provided as an input

    arn       = aws_ecs_cluster.main.arn
    rule      = aws_cloudwatch_event_rule.task_schedule.name
    role_arn  = aws_iam_role.cw_event_execution_role.arn

    ecs_target {
        launch_type         = "FARGATE"
        task_count          = var.task_count
        task_definition_arn = aws_ecs_task_definition.main.arn

        network_configuration {
            subnets         = var.subnet_ids
            security_groups = [ var.aws_security_group != null ? var.aws_security_group.id : aws_security_group.allow_outbound[0].id ]
            assign_public_ip = var.assign_public_ip
        }
    }
}
