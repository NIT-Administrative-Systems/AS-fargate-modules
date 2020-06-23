resource "aws_ecr_repository" "main" {
  name                 = "${var.task_name}-${var.env}"
  image_tag_mutability = "MUTABLE"
  tags                 = local.tags

  image_scanning_configuration {
    scan_on_push = true
  }
}

