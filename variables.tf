variable "name" {
  type        = string
  description = "Name of the API gateway"
}

variable "env" {
  type        = string
  description = "Environment prefix added to names"
}

variable "domain" {
  type        = string
  description = "Domain for custom domain"
  default     = ""
}

variable "sub_domain" {
  type        = string
  description = "Use this if your hosted zone is the whole domain"
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
      path : "foo"            # Required
      arn : ""                # ARN for resources, must be invoke arn for lambdas
      use_custom_auth : false # Optional, defaults to false
      use_api_key : false     # Optional, defaults to false
      use_vpc_link : false    # Optional does this need to go a VPC?
      method : "POST"         # Optional, defaults to POST
      endpoint : ""           # Endpoint only required for proxy integrations
      # arn also required for lambda
      name : ""             # Name of lambda function
      image_hosting : false # Set to true for image serving from s3
      key : ""              # Set to have s3 serve a single key instead of folder
      cache : false         # Turn on to enable request caching (not recommend most of the time)
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

variable "manual_redeploy" {
  type        = bool
  description = "Whether you want manual control over redeploys"
  default     = false
}
