locals {
    # Credit to Nick Evans:
    # https://github.com/NIT-Administrative-Systems/AS-serverless-api-IaC/blob/develop/locals.tf#L6

    # Remove any unaccaptable chars since we'll be using this for resource name
    clean_task_name = lower(replace(var.task_name, "/[^A-Za-z0-9_-]/", "-"))

    # Keep the task name shorter so we can be sure {task name}-{env} fits in all the resource names.
    task_short_name = lower("${substr(local.clean_task_name, 0, max(length(local.clean_task_name), 40))}")
}