# So TF knows when to re-generate the target group name
resource "random_id" "target_group_id" {
  keepers = {
    name = local.alb_target_group_name
    vpc_id = var.vpc_id
    target_type = "ip"
  }
  byte_length = 4
}

# Group of targets (EC2s, Lambdas, Containers, etc) traffic is sent to based on rules
resource "aws_lb_target_group" "lb_target_group" {
  name     = "${local.alb_target_group_name}-${random_id.target_group_id.hex}"
  port     = var.task_listening_port # different than ALB listener port. 
  protocol = "HTTP"
  deregistration_delay = var.deregistration_delay
  target_type = "ip" # If your service's task definition uses awsvpc network mode (required for Fargate launch type), you must choose IP as the target type. This is because tasks that use the awsvpc network mode are associated with an elastic network interface, not an Amazon Elastic Compute Cloud (Amazon EC2) instance.
  vpc_id = var.vpc_id

  health_check {
    healthy_threshold = var.hc_healthy_threshold
    unhealthy_threshold = var.hc_unhealthy_threshold
    timeout = var.hc_timeout
    interval = var.hc_interval
    path = var.hc_path
    matcher = var.hc_matcher
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_listener_rule" "lb_group_rule" {
  listener_arn = var.alb_listener_arn

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.lb_target_group.arn
  }
  
  condition {
    field  = "host-header"
    values = var.hostnames
   }
}
