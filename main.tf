locals {
  name_base   = "${var.env}-${var.name}"
  domain_name = "${var.domain}."

  # Used to set default values
  default_mapping = {
    use_custom_auth : false
    use_api_key : false
    endpoint : ""
    arn : ""
    method : "POST"
    cache : false
    image_hosting : false
    key: "",
    name: ""
  }
  resource_count    = length(local.mappings)
  mappings          = [for mapping in var.mappings : merge(local.default_mapping, mapping)] # Sets defaults if not present
  needs_lambda      = contains(local.mappings.*.use_custom_auth, true)
  has_custom_domain = var.domain != ""
  distinct_lambdas  = distinct(local.lambda_mappings.*.name)

  # Filtered lists of mappings by submodule they create
  s3_mappings     = [for item in local.mappings : item if lower(item.type) == "s3"]
  proxy_mappings  = [for item in local.mappings : item if lower(item.type) == "proxy"]
  sns_mappings    = [for item in local.mappings : item if lower(item.type) == "sns"]
  lambda_mappings = [for item in local.mappings: item if lower(item.type) == "lambda"]
  caching_enabled = contains(local.mappings.*.cache, true)
}

resource "aws_api_gateway_rest_api" "rest_api" {
  name        = "${local.name_base}-rest-api"
  description = var.api_description
}

resource "aws_api_gateway_stage" "stage" {
  stage_name           = local.name_base
  rest_api_id          = aws_api_gateway_rest_api.rest_api.id
  deployment_id        = aws_api_gateway_deployment.api_gateway_deployment.id
  xray_tracing_enabled = true

  cache_cluster_enabled = local.caching_enabled
  cache_cluster_size    = var.cache_cluster_size
}

resource "aws_api_gateway_deployment" "api_gateway_deployment" {
  description = "${local.name_base} deployment"
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  # Redeploys on change of any of the hashes returned by sub modules
  triggers = var.manual_redeploy ? {} : {
    redeployment = sha1(join(",", [
      jsonencode([join(",", concat(module.s3_integrations.*.redeployment_trigger_json))]),
      jsonencode([join(",", concat(module.sns_integrations.*.redeployment_trigger_json))]),
      jsonencode([join(",", concat(module.proxy_integrations.*.redeployment_trigger_json))]),
      jsonencode([join(",", concat(module.lambda_integrations.*.redeployment_trigger_json))])
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}
