module "fargate_resources" {
    source = "../modules"

    environment = "dev"

    account_resources_state_bucket  = "as-ado-sbx-tfstate"
    account_resources_state_file    = "as-ado-sbx-resources/sandbox/terraform.tfstate"
    account_resources_state_region  = "us-east-2"

    alb_state_bucket = "as-ado-sbx-tfstate"
    alb_state_file   = "as-fargate-service-example/alb/dev/terraform.tfstate"
    alb_state_region = "us-east-2"

    ecr_state_bucket  = "as-ado-sbx-tfstate"
    ecr_state_file    = "as-fargate-service-example/ecr/dev/terraform.tfstate"
    ecr_state_region  = "us-east-2"
}
