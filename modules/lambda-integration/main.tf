locals {
  name_base   = "${var.env}-${var.app_name}"
  custom_auth = var.custom_authorizer_id != ""
  path_parts  = split("/", var.path)
  is_sub_path = length(local.path_parts) > 1

  root_resource_id = aws_api_gateway_resource.proxy.id
}

resource "aws_api_gateway_resource" "path_root" {
  count       = local.is_sub_path ? 1 : 0
  rest_api_id = var.rest_api_id
  parent_id   = var.root_resource_id
  path_part   = local.path_parts[0]
}

resource "aws_api_gateway_resource" "proxy" {
  rest_api_id = var.rest_api_id
  parent_id   = local.is_sub_path ? aws_api_gateway_resource.path_root[0].id : var.root_resource_id
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "method" {
  rest_api_id      = var.rest_api_id
  resource_id      = local.root_resource_id
  http_method      = "ANY"
  authorization    = local.custom_auth == true ? "CUSTOM" : "NONE"
  authorizer_id    = local.custom_auth == true ? var.custom_authorizer_id : ""
  api_key_required = local.custom_auth != true && var.use_api_key == true
}

resource "aws_api_gateway_integration" "integration" {
  rest_api_id = var.rest_api_id
  resource_id = local.root_resource_id
  http_method = aws_api_gateway_method.method.http_method

  integration_http_method = "ANY" # should this always be POST?
  passthrough_behavior    = "WHEN_NO_TEMPLATES"
  credentials             = var.iam_role_arn
  type                    = "AWS_PROXY"
  uri                     = var.lamdba_invoke_arn
}

resource "aws_api_gateway_integration_response" "integration_response" {
  depends_on = [aws_api_gateway_integration.integration]

  rest_api_id = var.rest_api_id
  resource_id = local.root_resource_id
  http_method = aws_api_gateway_method.method.http_method
  status_code = aws_api_gateway_method_response.ok.status_code

  response_parameters = {
    "method.response.header.Timestamp"      = "integration.response.header.Date"
    "method.response.header.Content-Length" = "integration.response.header.Content-Length"
    "method.response.header.Content-Type"   = "integration.response.header.Content-Type"
  }
}

resource "aws_api_gateway_method_response" "ok" {
  rest_api_id = var.rest_api_id
  resource_id = local.root_resource_id
  http_method = aws_api_gateway_method.method.http_method
  status_code = 200

  response_parameters = {
    "method.response.header.Timestamp"      = true
    "method.response.header.Content-Length" = true
    "method.response.header.Content-Type"   = true
  }
}

resource "aws_api_gateway_method_settings" "settings" {
  count       = var.cache ? 1 : 0
  rest_api_id = var.rest_api_id
  stage_name  = var.stage_name
  method_path = "${var.path}/ANY"

  settings {
    metrics_enabled      = true
    logging_level        = var.env == "prod" ? "ERROR" : "INFO"
    caching_enabled      = var.cache
    cache_ttl_in_seconds = 300
  }
}
