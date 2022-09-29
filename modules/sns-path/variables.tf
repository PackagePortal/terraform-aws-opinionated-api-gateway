variable "rest_api_id" {
  type        = string
  description = "Rest API this path is attached to"
}

variable "sns_topic_arn" {
  type        = string
  description = "Arn of sns bucket to attach to"
}

variable "path" {
  type        = string
  description = "Path from root of gateway"
}

variable "iam_role_arn" {
  type        = string
  description = "Gateway IAM role"
}

variable "iam_role_name" {
  type        = string
  description = "IAM role name"
}

variable "env" {
  type        = string
  description = "Environment this is deployed in (e.g. dev or prod)"
}

variable "region" {
  type        = string
  description = "AWS Region gateway is deployed in"
}

variable "app_name" {
  type        = string
  description = "Self-descriptive"
}

variable "root_resource_id" {
  type        = string
  description = "Root api gateway path resource"
}

variable "custom_authorizer_id" {
  type        = string
  default     = ""
  description = "Custom authorizer id for path"
}

variable "use_api_key" {
  type        = bool
  default     = false
  description = "Whether to use custom api key"
}

variable "http_method" {
  type        = string
  default     = "POST"
  description = "HTTP method for integration"
}
