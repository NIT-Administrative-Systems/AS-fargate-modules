output "cluster_name" {
  value = aws_ecs_cluster.main.arn
}

output "task_definition" {
  value = aws_ecs_task_definition.main.arn
}

output "subnet_ids" {
  value = var.subnet_ids
}

output "security_group" {
  value = var.aws_security_group != null ? var.aws_security_group.id : aws_security_group.allow_outbound[0].id
}

output "task_short_name" {
    value = local.task_short_name
}

output "cw_log_group_name" {
    value = local.cloudwatch_log_group_name
}

output "cw_log_stream_prefix" {
    value = local.cloudwatch_log_stream_prefix
}

output "parameters" {
    value = zipmap(var.container_secrets, slice(aws_ssm_parameter.secure_param.*.name, 0, length(var.container_secrets)))
}

output "kms_arn" {
    value = aws_kms_key.key.arn
}