resource "aws_ecs_cluster" "main" {
  name = "${local.task_short_name}-${var.env}"
  tags = local.tags
}

# format secrets into name/valueFrom pairs for container definition 
locals {
  container_ssm_map = zipmap(var.container_secrets, slice(aws_ssm_parameter.secure_param.*.arn, 0, length(var.container_secrets)))
  container_ssm_secrets_list = [
    for k,v in local.container_ssm_map: 
      {"name":"${k}", "valueFrom":"${v}"}
  ]
}

resource "aws_ecs_task_definition" "main" {
  depends_on = [
      aws_iam_role.ecs_execution_role,
      aws_iam_role.ecs_task_role,
  ]

  family = var.task_family != null ? var.task_family : "${local.task_short_name}-${var.env}"

  # define the containers that are launched as part of a task
  # don't put this json as a separate template file data object bc uses a different provider and the order gets odd and doesn't get the updated valueFrom in the secrets map in time to update it in the task definition. 
  container_definitions    = <<EOF
  [
    {
      "name": "${local.task_short_name}-${var.env}",
      "image": "${var.ecr_repository_url}:${var.ecr_image_tag}",
      "requiresCompatibilities": [
        "FARGATE"
     ],
      "networkMode": "awsvpc",
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-stream-prefix": "${local.cloudwatch_log_stream_prefix}",
          "awslogs-region": "${var.region}",
          "awslogs-group": "${local.cloudwatch_log_group_name}"
        }
      },
      "environment": ${jsonencode(var.container_env_variables)},
      "secrets": ${jsonencode(local.container_ssm_secrets_list)},
      "portMappings": ${jsonencode(var.container_port_mappings)}
    }
  ]
  EOF
  
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.task_cpu
  memory                   = var.task_memory
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn

  tags = local.tags
}

resource "aws_ecs_service" "main" {
  name            = "${local.task_short_name}-${var.env}"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.main.arn
  launch_type     = "FARGATE"
  desired_count   = var.task_count # number of instances to start with on new deployment 

  # container health and rolling deployments
  deployment_minimum_healthy_percent = var.ecs_deploy_min_healthy_perc
  deployment_maximum_percent = var.ecs_deploy_max_perc
  health_check_grace_period_seconds = var.hc_grace_period

  network_configuration {
    subnets         = var.subnet_ids
    security_groups = [var.aws_security_group != null ? var.aws_security_group.id : aws_security_group.allow_outbound[0].id]
    assign_public_ip = var.assign_public_ip
  }

  depends_on = [
    aws_iam_role.ecs_task_role,
    aws_iam_role.ecs_execution_role,
    aws_cloudwatch_log_group.ecs,
  ]

  # register the service with the load balancer target group created 
  load_balancer {
    target_group_arn = aws_lb_target_group.lb_target_group.arn
    container_name   = "${local.task_short_name}-${var.env}" # as it appears in container definition 
    container_port   = var.task_listening_port
  }

  # Optional: Allow external changes without Terraform plan difference - needed so autoscaling not disrupted by terraform apply
  lifecycle {
    ignore_changes = [desired_count]
  }
}
