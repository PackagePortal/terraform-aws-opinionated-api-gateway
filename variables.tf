variable "name" {
  type        = string
  description = "Name of the API gateway"
}

variable "env" {
  type        = string
  description = "Terraform workspace usually - or dev/prod"
}

variable "domain" {
  type        = string
  description = "Domain for custom domain"
  default     = ""
}

variable "cache_cluster_size" {
  type        = string
  default     = "0.5"
  description = "Size of cache cluster"
}

variable "region" {
  type        = string
  description = "AWS region for deplyoment - e.g. us-west-1"
}

variable "mappings" {
  description = "Mapping objects that define paths"
  default = [
    {
      path : "foo"                # Required
      use_custom_auth : false     # Optional, defaults to false
      use_api_key : false         # Optional, defaults to false
      use_vpc_link : false        # Optional does this need to go a VPC?
      load_balancer_link_arn : "" # Required if use_vpc_link is true, expected to be api_gateway_vpc_link
      method : "POST"             # Optional, defaults to POST
      # One of endpoint or topic_arn are required, endpoint takes precedence if
      # both are specified
      endpoint : ""
      topic_arn : "" # Lets a message body get posted to SNS via AWS integration
      proxy : false  # If true will make the path greedy and all requests will get forwarded down it
    }
  ]
}

variable "auth_lambda_s3_bucket" {
  type        = string
  description = "If using custom auth the bucket with lamdba code in it"
  default     = ""
}

variable "auth_lambda_s3_key" {
  type        = string
  description = "If using custom auth the bucket with lamdba code in it"
  default     = ""
}

variable "auth_lambda_runtime" {
  type        = string
  default     = "nodejs12.x"
  description = "Runtime for authorization lambda"
}

variable "auth_lambda_env" {
  type        = map(string)
  default     = {}
  description = "Environment variables for lambda"
}

variable "auth_lambda_handler" {
  type        = string
  default     = "index.handler"
  description = "Method invoke signature for AWS Lambda authorizer"
}

variable "custom_auth_identity_source" {
  type        = string
  description = "Where in custom auth to find the authorization header"
  default     = "method.request.header.authorization"
}

variable "api_description" {
  type        = string
  description = "Description for API Gateway"
  default     = "API Gateway managed by terraform"
}
