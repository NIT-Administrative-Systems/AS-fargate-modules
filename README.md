# Admin Systems: Fargate Infrastructure-as-Code Modules

When referencing these modules in your IaC module's source, DO NOT reference the master branch as there may be breaking changes from future releases. Only reference a specific release tag, e.g. ?ref=v1.0.2
```
module "fargate_example" {
  source = "github.com/NIT-Administrative-Systems/AS-fargate-modules//modules/ecs_fargate_service?ref=v1.0.0"
  ...
}
```

## Fargate Task 

This is a Terraform IaC module for creating a fargate task with a single container, which runs on a schedule via cloudwatch event rule, and secrets management through SSM. It implements the Admin Systems practices outlined on our cloud practice site. This solution may be ideal for a serverless architecture which is resource-intensive or long-running enough to exceed the lambda duration/memory limitations e.g. periodic longer-running batch jobs, etc. 

When you push a new container image or apply a change to the task definition, future tasks launched will use the new version but any tasks already running will not recieve the changes. 

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
| aws_security_group | A terraformed aws_security_group resource to use. | No | Terraform aws_security_group resource | If none is provided, a security group will be created which allows outbound traffic. | 
| subnet_ids | One or more subnets for the fargate ENI to attach to. | Yes | list(string) | Required parameters do not have a default. | 
| assign_public_ip | Whether to assign a public IP address to the ENI | No | boolean | false |
| cw_status | Whether to enable or disable the cloudwatch rule | Yes | boolean | Required parameters do not have a default. | 
| cw_schedule | The cloudwatch schedule expression to use | No | string | null | 
| container_env_variables | A list of environment variable maps for your container. Do not include secrets. | No | list(object({name  = string, value = string})) | [] |
| container_secrets | A list of secrets to create in SSM and inject into the container at runtime. If updated, already running containers will not get new values/params. Names should match Jenkins credential IDs and will be available as env variables when the container runs. Do not use dashes/hyphens. | No | list(string) | [] |
| container_port_mappings | The list of port mappings for the container | No | list(object({containerPort = number, hostPort = number, protocol = string})) | [] |
| task_cpu | The number of CPU units reserved for the task (The container level will use the same value) | No | number | 256 |
| task_memory | The memory specified for the task level (The container level will use the same value) | No | number | 512 |
| aws_task_iam_policy_document | An IAM policy document granting permissions for other AWS services your task container is allowed to make calls to when it's running. | No | Terraform aws_iam_policy_document resource | null |
| task_count | Number of tasks to launch on the cluster. Increasing the task count increases the number of instances of your application. | No | number | 1 | 
| task_family | A name for multiple versions of the task definition | No | string | task_name-env |
| tags | A set of tag name and value pairs for tagging all applicable resources created - useful for cost visibility | No | map(string) | By default resources will be tagged with these standard AS tags: Application: task_name, Environment: env. Override these values by including them in your tags input map. | 


### Outputs
Available outputs from the modules:
| Name | Description |
| ---- | ----------- |
| parameters | Secret SSM parameters. Output is used by Jenkins to set the secret text. |
| kms_arn | The arn of the encryption key used for the SSM secrets so you can use it to encrypt elsewhere | 
| task_definition | The arn of the task definition created. Useful in AWS ECS cli commands e.g. to see if your task is running |  
| cluster_name | The name of the ecs cluster created. Useful in AWS ECS cli commands  e.g. to run a one-off task or see what's running on your cluster | 
| security_group | The id of the security group used. May be useful in AWS ECS cli commands, e.g. to run a one-off task | 
| subnet_ids | The list of subnet ids - may be useful in AWS ECS cli commands e.g. to run a one-off task |
| cw_log_group_name | The name of the cloudwatch log group created for your task. Useful for querying logs via AWS logs cli |
| cw_log_stream_prefix | The name of the cloudwatch log prefix for your task logs. Useful for querying logs via AWS logs cli |
| task_short_name | The task name (cleaned and shortened) used to name resources | 

### Complete Example
A complete end-to-end example implementing the shared Fargate Task module with an ECR repository, building the image, etc. for a simple Node.js application can be found in the [NUIT Administrative Systems Fargate Task Example repository](https://github.com/NIT-Administrative-Systems/as-fargate-task-example)

## Fargate Service
A service lets you specify how many copies of the task definition to run. This module runs a service behind an Application Load Balancer to distribute incoming traffic to containers (each with 1 task) in your service. Amazon ECS maintains that number of tasks and coordinates task scheduling with the load balancer. The module uses ECS Service Auto Scaling with target tracking to adjust the number of tasks in your service based on CPU and memory utilization targets.

If your service is not a customer-facing application, it is able to make use of the shared account ALB - see the AS Cloud Docs website. 

When `terraform apply` updates the task definition or you push a new ecr image, future tasks launched will use the new image and/or definition but any tasks already running will not recieve the changes. 
- If your updated image has the same tag as the image used by the currently running task-definition (e.g. "latest"), use the AWS CLI command for redeploying the service after image/task definitions are changed, e.g. using `aws ecs update-service --cluster <cluster name> --service <service name> --force-new-deployment` in a pipeline stage.
- If your updated image has a different tag, you will have to specify the updated value in the inputs to this module (variable ecr_image_tag), after which a `terraform apply` will create a new task definition (which will cause the service to be recreated). 


Fargate service charges are based on the vCPU and Memory resources while your containerized application is running, and the number of tasks running. This is in addition to charges for other AWS services used, such as the ALB traffic.

Examples using this module can be found in the module's examples sub-directory.

### Inputs
Available inputs to pass into the modules: 
| Name | Description | Required | Type | Default |
| ---- | ----------- | -------- | ---- | ------- |
| env | Short name for your app's environment | Yes | string | Required parameters do not have a default. | 
| task_name | Short name to identify your task | Yes | string | Required parameters do not have a default. | 
| region | AWS region to build in | Yes | string | Required parameters do not have a default. |

Task Definition Inputs
| Name | Description | Required | Type | Default |
| ---- | ----------- | -------- | ---- | ------- |
| task_cpu | The number of CPU units reserved for the task (The container level will use the same value) | No | number | 256 |
| task_memory | The memory specified for the task level (The container level will use the same value) | No | number | 512 |
| aws_task_iam_policy_document | An IAM policy document granting permissions for other AWS services your task container is allowed to make calls to when it's running. | No | Terraform aws_iam_policy_document resource | null |
| task_count | Number of tasks to launch on the cluster. Increasing the task count increases the number of instances of your application. | No | number | 1 | 
| task_family | A name for multiple versions of the task definition | No | string | task_name-env |
| tags | A set of tag name and value pairs for tagging all applicable resources created - useful for cost visibility | No | map(string) | By default resources will be tagged with these standard AS tags: Application: task_name, Environment: env. Override these values by including them in your tags input map. | 

Container Definition Inputs
| Name | Description | Required | Type | Default |
| ---- | ----------- | -------- | ---- | ------- |
| container_env_variables | A list of environment variable maps for your container. Do not include secrets. | No | list(object({name  = string, value = string})) | [] |
| container_secrets | A list of secrets to create in SSM and inject into the container at runtime. If updated, already running containers will not get new values/params. Names should match Jenkins credential IDs and will be available as env variables when the container runs. Do not use dashes/hyphens. | No | list(string) | [] |
| container_port_mappings | The list of port mappings for the container | No | list(object({containerPort = number, hostPort = number, protocol = string})) | [] |

ECR Inputs
| Name | Description | Required | Type | Default |
| ---- | ----------- | -------- | ---- | ------- |
| ecr_repository_url | ECR repository url to pull image from to start the container | Yes | string | Required parameters do not have a default. | 
| ecr_repository_arn | ECR repositiory arn (to grant task necessary IAM permissions) | Yes | string | Required parameters do not have a default. | 
| ecr_image_tag | ECR image tag to pull for starting the container | No | string | "latest" |

Task Networking Inputs
| Name | Description | Required | Type | Default |
| ---- | ----------- | -------- | ---- | ------- |
| vpc_id | The VPC id to run in. Fargate task definitions require that the network mode is set to awsvpc. The awsvpc network mode provides each task with its own elastic network interface. | Yes | string | Required parameters do not have a default. | 
| aws_security_group | A terraformed aws_security_group resource to use. | No | Terraform aws_security_group resource | If none is provided, a security group will be created which allows outbound traffic. | 
| subnet_ids | One or more subnets for the fargate ENI to attach to. | Yes | list(string) | Required parameters do not have a default. | 
| assign_public_ip | Whether to assign a public IP address to the ENI | No | boolean | false |
| alb_security_group_id | The security group id of the ALB. Used to allow inbound traffic from the ALB to your Fargate service | yes | string | Required parameters do not have a default. |
| task_listening_port | The port exposed exposed by your container. Will be used by the ALB to communicate with your container. | no | number | 8080 | 

Application Load Balancer Inputs
| Name | Description | Required | Type | Default |
| ---- | ----------- | -------- | ---- | ------- |
| alb_listener_arn | The ARN of an existing alb listener. | Yes | string | Required parameters do not have a default |
| deregistration_delay | After deregistering a task from the load balancer, the amount of time (seconds) for the load balancer to wait on draining active connections before changing task to unused. | No | Number | 300 | 
| hostnames | The hostnames for your application. Used by the ALB listener to route traffic. | Yes | list(string) | Required parameters do not have a default. | 

Auto Scaling Inputs
| Name | Description | Required | Type | Default |
| ---- | ----------- | -------- | ---- | ------- |
| min_capacity | The minimum number of tasks to run. 
| max_capacity | The maximum number of tasks to run. High enough that you can scale for traffic but low enough you don't overspend | 
| cpu_target | Target cpu utilization. | No | number | 75 |
| cpu_scalein_cooldown | The minimum time (seconds) after a cpu scalein before subsequent cpu scalein events. e.g. reduce costs by allowing faster scale-in than the default AWS 300. | No | number | 180 |
| cpu_scaleout_cooldown | The minimum time (seconds) after a cpu scaleout before subsequent cpu scaleout events. Set at least as long as it takes for your cpu load to normalize after scaling out so you don't overscale. | No | number | 180 |
| memory_target | Target memory utilization. | No | number | 75 |
| memory_scalein_cooldown | The minimum time (seconds) after a memory scalein before subsequent memory scalein events. e.g. reduce costs by allowing faster scale in  than the default AWS 300. | No | number | 180 |
| memory_scaleout_cooldown | The minimum time (seconds) after a memory scaleout before subsequent memory scaleout events. Set at least as long as it takes for your memory load to normalize after scaling out so you don't overscale. | No | number | 180 | 
| service_shutdown_schedules | Specifies times for stopping the service and restarting it again, e.g. to save costs by stopping dev/test on nights/weekends. The shutdown/startup string values must be AWS Scheduling Expressions and can be recurring crons or one-time events. Use short descriptive names as the keys for the startup/shutdown pairs. | No | map(map(object({shutdown  = string, startup = string}))) | {} |

Load Balancer Health Check Inputs:
The load balancer sends periodic requests to the registered tasks to check their status. It will replace unhealthy tasks. 
| Name | Description | Required | Type | Default |
| ---- | ----------- | -------- | ---- | ------- |
| hc_healthy_threshold | The number of successful health checks to be considered a healthy task | No | number | 4 |
| hc_unhealthy_threshold | The number of failed health checks to be considered an unhealthy task | No | number | 2 | 
| hc_timeout | The time (seconds) after which no response indicates an unhealthy task. | No | number | 15 |
| hc_interval | The time (seconds) between health checks of a task. Min 5, Max 300. | No | number | 60 |
| hc_path | The path for the healthcheck request. | No | string | /healthcheck |
| hc_matcher | The response code required for a successful health check response. May be a single value, a list of values as a string, or a range of values as a string. | No | string | 200 |

ECS Service Health Check Inputs:
The ecs service scheduler may also do health checks. 
| Name | Description | Required | Type | Default |
| ---- | ----------- | -------- | ---- | ------- |
| hc_grace_period | The time (seconds) to wait after the container status is in the RUNNING state before health checks are considered. This prevents prematurely shutting down new tasks as UNHEALTHY when they are known to take awhile to start up after the container is running. | No | number | 30 |

ECS Service Deployment Inputs: 
| Name | Description | Required | Type | Default |
| ---- | ----------- | -------- | ---- | ------- |
| ecs_deploy_min_healthy_perc | The lower limit on how many healthy tasks must remain RUNNING during ECS rolling update deployment. If set to less than 100, enables you ECS to free up cluster capacity before starting new tasks so you can deploy without using additional cluster capacity | No | number | 100 |
| ecs_deploy_max_perc | The upper limit on how many RUNNING/PENDING/DRAINING tasks there may be during deployment. This controls the deployment batch size; deployment batches may be used to avoid downtime in case a deployment is faulty and fails. | No | number | 200 |

### Outputs
Available outputs from the modules:
| Name | Description |
| ---- | ----------- |
| parameters | Secret SSM parameters. Output is used by Jenkins to set the secret text. |
| service_name | The name of the ECS service. Useful in AWS ECS cli commands, e.g. to redeploy the service after pushing a new image | 
| cluster_name | The name of the ecs cluster created. Useful in AWS ECS cli commands, e.g. to redeploy the service after pushing a new image | 
| kms_arn | The arn of the encryption key used for the SSM secrets so you can use it to encrypt elsewhere | 
| task_definition | The arn of the task definition created. |  
| security_group | The id of the security group used. | 
| subnet_ids | The list of subnet ids. |
| cw_log_group_name | The name of the cloudwatch log group created for your task. Useful for querying logs via AWS logs cli |
| cw_log_stream_prefix | The name of the cloudwatch log prefix for your task logs. Useful for querying logs via AWS logs cli |
| task_short_name | The task name (cleaned and shortened) used to name resources | 

### Complete Example
A complete end-to-end example implementing the shared Fargate Service module with an ECR repository, building the image, etc. for a simple Node/Express application can be found in the [NUIT Administrative Systems Fargate Service Example repository](https://github.com/NIT-Administrative-Systems/as-fargate-service-example)

## Contributing
Find another input you would like parameterized? Need another output? Want to clarify something in the documentation? Pull requests welcome!
