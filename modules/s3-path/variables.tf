variable "rest_api_id" {
  type        = string
  description = "Rest API this path is attached to"
}

variable "s3_bucket_arn" {
  type        = string
  description = "Arn of s3 bucket to attach to"
}

variable "stage_name" {
  type        = string
  description = "AWS API gateway stage name"
}

variable "path" {
  type        = string
  description = "Path from root of gateway"
}

variable "region" {
  type        = string
  description = "AWS region this is deployed in"
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
  default     = "GET"
  description = "HTTP Method for integration with S3"
}

variable "cache" {
  type        = bool
  default     = false
  description = "Whether to use custom api key"
}

variable "image_host" {
  type        = bool
  description = "Whether content should be returned as binary for hosting images"
  default     = false
}

variable "key" {
  type        = string
  description = "Default S3 key to use"
  default     = ""
}
