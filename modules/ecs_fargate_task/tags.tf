locals {
    tags = {
        Application = var.task_name
        Environment = var.env
    }
}
