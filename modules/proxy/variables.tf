variable "rest_api_id" {
  type        = string
  description = "Rest API this path is attached to"
}

variable "path" {
  type        = string
  description = "Path from root of gateway"
}

variable "stage_name" {
  type        = string
  description = "AWS API gateway stage name"
}

variable "iam_role_arn" {
  type        = string
  description = "Gateway IAM role"
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

variable "load_balancer_link_arn" {
  type        = string
  default     = ""
  description = "Optional arn to an ALB that is linked behind this proxy"
}

variable "endpoint" {
  type        = string
  default     = ""
  description = "Endpoint to proxy to if not a VPC link"
}

variable "cache" {
  type        = bool
  default     = false
  description = "Whether to use custom api key"
}
