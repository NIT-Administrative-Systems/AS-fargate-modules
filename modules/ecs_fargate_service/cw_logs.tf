locals {
    # define reusably so we can refer to it in container defn and outputs
    cloudwatch_log_group_name = "/aws/ecs/fargate-svc/${local.task_short_name}-${var.env}"
    cloudwatch_log_stream_prefix = "/task"
}

resource "aws_cloudwatch_log_group" "ecs" {
    name              = local.cloudwatch_log_group_name
    tags              = local.tags

    retention_in_days = 30
}
