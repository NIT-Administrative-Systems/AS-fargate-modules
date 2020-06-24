resource "aws_cloudwatch_event_rule" "task_schedule" {
    name                = "${var.task_name}-${var.env}"
    schedule_expression = var.is_dst ? var.dst_on_schedule : var.dst_off_schedule
    is_enabled          = var.cw_status
    tags                = local.tags
}

resource "aws_cloudwatch_event_target" "ecs_scheduled_task" {
    arn       = aws_ecs_cluster.main.arn
    rule      = aws_cloudwatch_event_rule.task_schedule.name
    role_arn  = aws_iam_role.cw_event_execution_role.arn

    ecs_target {
        launch_type         = "FARGATE"
        task_count          = 1
        task_definition_arn = aws_ecs_task_definition.main.arn

        network_configuration {
            subnets         = data.aws_subnet_ids.account_pvt.ids
            security_groups = [aws_security_group.allow_outbound.id]
        }
    }
}
