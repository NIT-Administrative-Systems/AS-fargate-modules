# Admin Systems: Farget Infrastructure-as-Code Modules

## Fargate Task 

This is a Terraform IaC module for creating a fargate task with a single container, which runs on a schedule via cloudwatch event rule, and secrets management through SSM. It implements the Admin Systems practices outlined on our cloud practice site. This solution may be ideal for a serverless architecture which is resource-intensive or long-running enough to exceed the lambda duration/memory limitations e.g. periodic longer-running batch jobs, etc. 

Fargate task charges are based on the vCPU and Memory resources while your containerized application is running. 

Examples using this module can be found in the module's examples sub-directory.

### Inputs
Available inputs to pass into the modules: 
| Name | Description | Required | Type | Default |
| ---- | ----------- | -------- | ---- | ------- |
| env | Short name for your app's environment | Yes | string | Required parameters do not have a default. | 
| task_name | Short name to identify your task | Yes | string | Required parameters do not have a default. | 
| region | AWS region to build in | Yes | string | Required parameters do not have a default. |
| ecr_repository_url | ECR repository url to pull image from to start the container | Yes | string | Required parameters do not have a default. | 
| ecr_repository_arn | ECR repositiory arn (to grant task necessary IAM permissions) | Yes | string | Required parameters do not have a default. | 
| ecr_image_tag | ECR image tag to pull for starting the container | No | string | "latest" |
| vpc_id | The VPC id to run in. Fargate task definitions require that the network mode is set to awsvpc. The awsvpc network mode provides each task with its own elastic network interface. | Yes | string | Required parameters do not have a default. | 
| subnet_ids | One or more subnets for the fargate ENI to attach to. | Yes | list(string) | Required parameters do not have a default. | 
| assign_public_ip | Whether to assign a public IP address to the ENI | No | boolean | false |
| cw_status | Whether to enable or disable the cloudwatch rule | Yes | boolean | Required parameters do not have a default. | 
| cw_is_dst | DST true for summer (UTC-5) or DST false for winter (UTC-6). You are responsible for redeploying when this changes. |  Yes | boolean | Required parameters do not have a default. | 
| cw_is_dst_schedule | The cloudwatch schedule to use when | Yes | string | Required parameters do not have a default. | 
| cw_not_dst_schedule | A cloudwatch schedule to use when non-DST | Yes | string | Required parameters do not have a default. | 
| container_env_variables | A list of environment variable maps for your container. Do not include secrets. | No | list(object({name  = string, value = string})) | [] |
| container_secrets | A list of secrets to create in SSM and inject into the container at runtime. If updated, already running containers will not get new values/params. Names should match Jenkins credential IDs and will be available as env variables when the container runs. Do not use dashes/hyphens. | No | list(string) | [] |
| container_port_mappings | The list of port mappings for the container | No | list(object({containerPort = number, hostPort = number, protocol = string})) | [] |
| task_cpu | The number of CPU units reserved for the task (The container level will use the same value) | No | number | 256 |
| task_memory | The memory specified for the task level (The container level will use the same value) | No | number | 512 |
| task_iam_policy | An IAM policy document granting permissions for other AWS services your task container is allowed to make calls to when it's running. | No | Terraform aws_iam_policy_document resource | null |
| task_count | Number of tasks to launch on the cluster. Increasing the task count increases the number of instances of your application. | No | number | 1 | 
| task_family | A name for multiple versions of the task definition | No | string | task_name-env |


### Outputs
Available outputs from the modules:
| Name | Description |
| ---- | ----------- |
| parameters | Secret SSM parameters. Output is used by Jenkins to set the secret text. |
| kms_arn | The arn of the encryption key used for the SSM secrets so you can use it to encrypt elsewhere | 
| task_definition | The arn of the task definition created. Useful in AWS ECS cli commands e.g. to see if your task is running |  
| cluster_name | The name of the ecs cluster created. Useful in AWS ECS cli commands  e.g. to run a one-off task or see what's running on your cluster | 
| security_group | The id of the security group created. May be useful in AWS ECS cli commands, e.g. to run a one-off task | 
| subnet_ids | The list of subnet ids - may be useful in AWS ECS cli commands e.g. to run a one-off task |
| cw_log_group_name | The name of the cloudwatch log group created for your task. Useful for querying logs via AWS logs cli |
| cw_log_stream_prefix | The name of the cloudwatch log prefix for your task logs. Useful for querying logs via AWS logs cli |
| task_short_name | The task name (cleaned and shortened) used to name resources | 

## Complete Example
A complete end-to-end example implementing implementing the shared Fargate Task module with an ECR repository, building the image, etc. for a simple Node.js application can be found in the [NUIT Administrative Systems Fargate Task Example repository](https://github.com/NIT-Administrative-Systems/as-fargate-task-example)

## Contributing
Find another input you would like parameterized? Need another output? Pull requests welcome! Want to clarify something in the documentation? Pull requests welcome!

## Known issues 
There is a Terraform or AWS bug causing the task definition template to only update the name property of the secrets and ignore the updated valueFrom in the updated map variable, so valueFrom property doesn't get the new ARN when the container secrets list changes until second deploy. Fixed by adding a depends_on to the task definition template, however the way Terraform handles a depends_on in a template causes it to destroy and recreate  a new task definition revision in the task family every time you run `terraform apply`.
