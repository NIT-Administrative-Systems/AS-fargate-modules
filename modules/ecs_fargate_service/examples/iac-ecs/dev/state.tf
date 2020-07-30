terraform {
  backend "s3" {
    bucket = "as-ado-sbx-tfstate"
    key    = "example-ecs-service/dev/terraform.tfstate"
    region = "us-east-2"
  }
}

