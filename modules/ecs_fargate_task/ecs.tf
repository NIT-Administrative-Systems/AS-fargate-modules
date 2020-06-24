resource "aws_ecs_cluster" "main" {
  name = "${var.task_name}-${var.env}"
  tags = local.tags
}

data "template_file" "fargate_container_definition" {
  template      = <<EOF
  [
    {
      "name": "${var.task_name}",
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
      "environment": [
        { "name" : "task_name", "value": "${var.task_name}" },
        { "name" : "env", "value": "${var.env}" }
      ]
    }
  ]
  EOF
}

resource "aws_ecs_task_definition" "main" {
  depends_on = [
      aws_iam_role.ecs_execution_role,
      aws_iam_role.ecs_task_role
  ]

  family = "${var.task_name}-${var.env}"

  # define the containers that are launched as part of a task
  container_definitions    = data.template_file.fargate_container_definition.rendered
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.fargate_cpu
  memory                   = var.fargate_memory
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn

  tags = local.tags
}
