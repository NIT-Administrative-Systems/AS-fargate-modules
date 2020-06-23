output "cluster_name" {
  value = aws_ecs_cluster.main.arn
}

output "task_definition" {
  value = aws_ecs_task_definition.nodejs_task.arn
}

output "subnet_ids" {
  value = data.aws_subnet_ids.account_pvt.ids
}

output "security_group" {
  value = aws_security_group.allow_outbound.id
}

output "task_name" {
    value = var.task_name # used in containername override
}

output "cw_log_group_name" {
    value = local.cloudwatch_log_group_name
}

output "cw_log_stream_prefix" {
    value = local.cloudwatch_log_stream_prefix
}
