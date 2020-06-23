# Security
data "aws_vpc" "account_main" {
  id = var.vpc_id
}

# shared private subnets for the account - could also get from shared state if added to outputs
data "aws_subnet_ids" "account_pvt" {
  vpc_id = data.aws_vpc.account_main.id
  filter {
    name   = "tag:Name"
    values = var.subnet_name_tags
  }
}

# Traffic to/from the ECS Cluster
resource "aws_security_group" "allow_outbound" {
  name        = "${var.task_name}-${var.env}"
  description = "sg for ${var.task_name} ECS cluster outbound traffic - ${var.env}"
  vpc_id      = data.aws_vpc.account_main.id
  tags        = local.tags

  # outbound traffic needed for NAT Gateway and outside API calls
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # equivalent of ALL which is not allowed here
    cidr_blocks = ["0.0.0.0/0"]
  }
}
