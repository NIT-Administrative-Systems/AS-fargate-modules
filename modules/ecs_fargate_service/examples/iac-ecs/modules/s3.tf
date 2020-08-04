# This is just an example of other resources you might be building outside the shared module
# For which you can give IAM permissions to the fargate tasks as needed
resource "aws_s3_bucket" "example" {
  bucket = "${var.app_name}-example-bucket-${var.environment}"
  acl    = "private"

  tags = local.tags
}

