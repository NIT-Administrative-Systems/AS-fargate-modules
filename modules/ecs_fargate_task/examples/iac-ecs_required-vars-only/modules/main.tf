# Build the Shared Module Infrastructure
# This example sets only the required vars and use defaults/unset for the rest
module "build_fargate_task" {
  source = "github.com/NIT-Administrative-Systems/AS-fargate-modules//modules/ecs_fargate_task?ref=master"

  env         = var.environment
  task_name   = var.app_name
  region      = var.region

  ecr_repository_url = data.terraform_remote_state.ecr.outputs.ecr_repository_url
  ecr_repository_arn = data.terraform_remote_state.ecr.outputs.ecr_repository_arn

  vpc_id     = data.terraform_remote_state.shared_resources.outputs.vpc_id
  subnet_ids = ["subnet-002338fccd5226b4d", "subnet-096ed7911d904ef89"] # TODO - remote state

  cw_status             = true 
  cw_is_dst             = true 
  cw_is_dst_schedule    = "cron(30 21 ? * MON-FRI *)"
  cw_not_dst_schedule   = "cron(30 22 ? * MON-FRI *)"
}