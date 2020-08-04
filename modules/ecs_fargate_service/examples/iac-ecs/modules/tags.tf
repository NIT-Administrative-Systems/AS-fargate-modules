locals {
    tags = {
        Application = var.app_name
        Env = var.environment
    }
}