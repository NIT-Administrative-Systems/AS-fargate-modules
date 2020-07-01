# Traffic to/from the ECS Cluster
resource "aws_security_group" "allow_outbound" {
  count = var.aws_security_group != null ? 0 : 1 # only create if a security group resource is not provided as an input

  name        = "${local.task_short_name}-${var.env}"
  description = "sg for ${local.task_short_name} ECS cluster outbound traffic - ${var.env}"
  vpc_id      = var.vpc_id
  tags        = local.tags

  # outbound traffic needed for NAT Gateway and outside API calls
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # equivalent of ALL which is not allowed here
    cidr_blocks = ["0.0.0.0/0"]
  }
}
