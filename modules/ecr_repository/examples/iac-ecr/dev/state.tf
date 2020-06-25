terraform {
  backend "s3" {
    bucket = "as-ado-sbx-tfstate"
    key    = "ecr-shared-module-example/dev/terraform.tfstate"
    region = "us-east-2"
  }
}

