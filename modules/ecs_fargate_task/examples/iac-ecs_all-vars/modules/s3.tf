# This is just an example of other resources you might be building outside the shared module
# For which you can give IAM permissions to the fargate task as needed
resource "aws_s3_bucket" "example" {
  bucket = "just-an-example-bucket"
  acl    = "private"
}

