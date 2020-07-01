locals {
    as_standard_tags = {
        Application = var.task_name
        Environment = var.env
    }

    tags = merge(local.as_standard_tags, var.tags)     # if tags of the same name are specified in the user's map it will just overwrite with the last value specified. 
}
