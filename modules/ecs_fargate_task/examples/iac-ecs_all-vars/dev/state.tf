terraform {
  backend "s3" {
    bucket = "as-ado-sbx-tfstate"
    key    = "example_all_vars/ecs/dev/terraform.tfstate"
    region = "us-east-2"
  }
}

