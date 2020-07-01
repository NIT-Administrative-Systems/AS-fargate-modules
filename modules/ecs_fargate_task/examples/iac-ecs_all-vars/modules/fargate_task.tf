# Build the Shared Module Infrastructure
# This example sets all required and optional vars for more customization
module "fargate_task" {
  source = "github.com/NIT-Administrative-Systems/AS-fargate-modules//modules/ecs_fargate_task?ref=master"

  env         = var.environment
  task_name   = var.app_name
  region      = var.region

  ecr_repository_url = data.terraform_remote_state.ecr.outputs.ecr_repository_url
  ecr_repository_arn = data.terraform_remote_state.ecr.outputs.ecr_repository_arn
  ecr_image_tag      = "version2.0"

  task_iam_policy  = data.aws_iam_policy_document.example_ecs_task_policy
  task_cpu         = 512
  task_memory      = 1024
  task_family      = "example_family_4"
  task_count       = 2

  vpc_id     = data.terraform_remote_state.shared_resources.outputs.vpc_id
  subnet_ids = ["subnet-002338fccd5226b4d", "subnet-096ed7911d904ef89"] # TODO - remote state
  assign_public_ip = true

  cw_status             = true # rule enabled (true) or disabled (false)
  cw_schedule    = "cron(30 21 ? * MON-FRI *)" # cloudwatch schedule to use when DST is true 

  # Do not include secret values here (passwords, API tokens, etc)
  # List of maps e.g. [{name = "env", value = "dev"}, {name = "task_name", value = "my_task"}]
  container_env_variables = [
    { 
      name = "task_name",
      value = var.app_name
    },
    {
      name = "env",
      value = var.environment
    }
  ]

  /*
  * List of SSM Parameters to create for secrets
  * These names should match the Jenkins credential IDs. 
  * SSM values will be injected into container when it starts up and available as environment variables 
  * These names will match the name of the env variable in the container
  * Do not use dashes/hyphens in these names because they can't be set as environment variables
  */
  container_secrets = ["my_secret_password"]

  # format: list of maps e.g. [{hostPort = 443, protocol = "tcp", containerPort = 443}]
  container_port_mappings = [
    {
      hostPort = 443, 
      protocol =  "tcp", 
      containerPort = 443
    },
    {
      hostPort = 4443, 
      protocol = "tcp", 
      containerPort = 4443
    }
  ]
}