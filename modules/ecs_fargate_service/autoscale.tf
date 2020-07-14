resource "aws_appautoscaling_target" "ecs_target" {
  service_namespace  = "ecs"
  resource_id        = "service/${aws_ecs_cluster.main.name}/${aws_ecs_service.main.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  min_capacity       = var.min_capacity
  max_capacity       = var.max_capacity
}

# Target Tracking - set metric and target value 
# ECS Auto Scaling creates and manages cloudwatch alarms and calculates scaling adjustment
resource "aws_appautoscaling_policy" "ecs_targettracking_cpu" {
  name               = "cpu-gt-75:${aws_appautoscaling_target.ecs_target.resource_id}"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }

    target_value = var.cpu_target # scale out when cpu above 75
    # optional
    scale_in_cooldown = var.cpu_scalein_cooldown # time in seconds after a scale_in that it can scale_in again
    scale_out_cooldown = var.cpu_scaleout_cooldown # time in seconds after a scale_out that it can scale_out again
  }
}


resource "aws_appautoscaling_policy" "ecs_targettracking_mem" {
  name               = "mem-gt-75:${aws_appautoscaling_target.ecs_target.resource_id}"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }

    target_value = var.memory_target
    scale_in_cooldown = var.memory_scalein_cooldown # time in seconds after a scale_in that it can scale_in again
    scale_out_cooldown = var.memory_scaleout_cooldown # time in seconds after a scale_out that it can scale_out again
  }
}
