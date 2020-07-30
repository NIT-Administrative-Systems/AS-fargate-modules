# Build the shared module infrastructure
module "fargate_task" {
  source = "github.com/NIT-Administrative-Systems/AS-fargate-modules//modules/ecs_fargate_service?ref=master"

  env         = var.environment
  task_name   = var.app_name
  region      = var.region

  ecr_repository_url = data.terraform_remote_state.ecr.outputs.ecr_repository_url
  ecr_repository_arn = data.terraform_remote_state.ecr.outputs.ecr_repository_arn

  alb_listener_arn = data.terraform_remote_state.alb_listener.outputs.alb_listener_arn
  hostnames = data.terraform_remote_state.alb_listener.outputs.domain_names

  vpc_id     = data.terraform_remote_state.account_resources.outputs.vpc_id
  subnet_ids = data.terraform_remote_state.account_resources.outputs.private_subnet_ids
  alb_security_group_id = data.terraform_remote_state.account_resources.outputs.lb_security_group_id

  # Do not include secret values (passwords, API tokens, etc)
  # list of maps e.g. [{name = "test12", env = "dev"}]
  container_env_variables = [
    { 
      name = "task_name",
      value = var.app_name
    },
    {
      name = "env",
      value = var.environment
    },
    {
      name = "NODE_ENV",
      value = "production"
    },
    {
      name = "NODE_OPTIONS",
      value = "--max-old-space-size=500"
    }
  ]

  /*
  * List of SSM Parameters to create for secrets
  * These names should match the Jenkins credential IDs. 
  * SSM values will be injected into container when it starts up and available as environment variables 
  * These names will match the name of the env variable in the container
  * Do not use dashes/hyphens in these names because they can't be set as environment variables
  */
  container_secrets = ["my_secret_password", "test_123"]

  container_port_mappings = [
    { 
      containerPort = 8080, 
      protocol = "tcp",
      hostPort = 8080 # must match containerPort for awsvpc mode (which is required for FARGATE launch type)
    }
  ]

  tags = {
    test_tag = "testtag-1234" # add a supplemental tag 
    Application = "myapp" # override the default Application tag value 
  }

  deregistration_delay = 45

  # auto scaling
  min_capacity = 1
  max_capacity = 4

}