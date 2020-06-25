resource "aws_cloudwatch_event_rule" "task_schedule" {
    name                = "${local.task_short_name}-${var.env}"
    schedule_expression = var.cw_is_dst ? var.cw_dst_on_schedule : var.cw_dst_off_schedule
    is_enabled          = var.cw_status
    tags                = local.tags
}

resource "aws_cloudwatch_event_target" "ecs_scheduled_task" {
    arn       = aws_ecs_cluster.main.arn
    rule      = aws_cloudwatch_event_rule.task_schedule.name
    role_arn  = aws_iam_role.cw_event_execution_role.arn

    ecs_target {
        launch_type         = "FARGATE"
        task_count          = var.task_count
        task_definition_arn = aws_ecs_task_definition.main.arn

        network_configuration {
            subnets         = var.subnet_ids
            security_groups = [aws_security_group.allow_outbound.id]
        }
    }
}
