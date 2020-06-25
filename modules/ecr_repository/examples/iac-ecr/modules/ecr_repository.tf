# Create the infrastructure
module "build_ecr_repo" {
  source = "github.com/NIT-Administrative-Systems/AS-fargate-modules//modules/ecr_repository?ref=master"

  env       = var.environment
  task_name = "fargate_module_poc"
  region    = "us-east-2"
}