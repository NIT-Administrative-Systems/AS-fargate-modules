
resource "aws_kms_key" "key" {
  description = "Key for encrypting ${var.task_name} secrets - ${var.env}"
}

resource "aws_ssm_parameter" "secure_param" {
  count = length(var.container_secrets)

  name        = "/${var.task_name}/${var.env}/${var.container_secrets[count.index]}"
  description = "Fargate Task secret: ${var.container_secrets[count.index]}"
  type        = "SecureString"
  value       = "SSM parameter store not populated from Jenkins"
  key_id      = aws_kms_key.key.arn

  # The parameter will be created with a dummy value. Jenkins will update it with 
  # the final value in a subsequent pipeline step.
  #
  # TF will not override the parameter once it has been created.
  lifecycle {
    ignore_changes = [value]
  }
}

locals {
    container_ssm_map = zipmap(var.container_secrets, slice(aws_ssm_parameter.secure_param.*.arn, 0, length(var.container_secrets)))
}

output "parameters" {
    value = zipmap(var.container_secrets, slice(aws_ssm_parameter.secure_param.*.name, 0, length(var.container_secrets)))
}