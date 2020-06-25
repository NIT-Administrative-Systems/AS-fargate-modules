terraform {
  backend "s3" {
    bucket = "as-ado-sbx-tfstate"
    key    = "example_required_vars_only/ecs/dev/terraform.tfstate"
    region = "us-east-2"
  }
}

