output "parameters" {
    value = module.build_fargate_task.parameters
}

output "cluster_name" {
  value = module.build_fargate_task.cluster_name
}
