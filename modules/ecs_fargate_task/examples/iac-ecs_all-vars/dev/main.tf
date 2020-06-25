module "ecs_resources" {
    source = "../modules"

    environment = "dev"

    account_resources_state_bucket  = "as-ado-sbx-tfstate"
    account_resources_state_file    = "as-ado-sbx-resources/sandbox/terraform.tfstate"
    account_resources_state_region  = "us-east-2"

    ecr_state_bucket  = "as-ado-sbx-tfstate"
    ecr_state_file    = "fargate_module_poc/ecr/dev/terraform.tfstate"
    ecr_state_region  = "us-east-2"
}
