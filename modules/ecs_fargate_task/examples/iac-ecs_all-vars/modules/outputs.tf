output "parameters" {
    value = module.fargate_task.parameters
}

output "cluster_name" {
  value = module.fargate_task.cluster_name
}
