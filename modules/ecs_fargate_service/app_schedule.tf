# specify the new capacity - specify minimum, maximum, or both
# autoscaling will scale to the specified capacity at the scheduled time
# Scheduled Action does not keep track of old values and return to them after the end time
# so you must have a second action that returns it to the previous value at a certain time

# shutdown schedule
# if value for max is below the current capacity, autoscaling scales in to maxcapacity
resource "aws_appautoscaling_scheduled_action" "shutdown" {
  for_each = var.service_shutdown_schedules

  name               = "${var.task_name}-shutdown-${each.key}-${var.env}"
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  schedule           = each.value["shutdown"]
  
  scalable_target_action {
    max_capacity = 0
  }
}

# startup schedule
# if value for min is above the current capacity, autoscaling scales out to min capacity
resource "aws_appautoscaling_scheduled_action" "startup" {
  for_each = var.service_shutdown_schedules

  name               = "${var.task_name}-startup-${each.key}-${var.env}"
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  schedule           = each.value["startup"]

  scalable_target_action {
    min_capacity = var.min_capacity # return to normal target tracking autoscaling rules. count will be raised to min and then target tracking will decide whether it needs further scaling out. 
    max_capacity = var.max_capacity # re-raise max capacity or it won't let you set the min_capacity to above it   
  }
}
