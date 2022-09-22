locals {
  name_base   = "${var.env}-${var.app_name}"
  custom_auth = var.custom_authorizer_id != ""
  # final part of arn is a name
  bucket_name = split(":", var.s3_bucket_arn)[length(split(":", var.s3_bucket_arn)) - 1]
  clean_path  = trim(var.path, "/")
  has_parent  = length(local.split_path) > 1
  parent_id   = local.has_parent ? aws_api_gateway_resource.path_root[0].id : var.root_resource_id
  resource_id = local.clean_path != "" ? aws_api_gateway_resource.item[0].id : var.root_resource_id
  split_path  = split("/", local.clean_path)
  child_path  = local.split_path[length(local.split_path) - 1]
  is_proxy    = local.child_path == "{proxy+}"
  s3_key      = var.key != "" ? var.key : local.is_proxy ? "{proxy}" : local.child_path
  iam_path    = replace(var.path, "//|{|}|\\+/", "")
}

resource "aws_api_gateway_resource" "path_root" {
  count       = local.has_parent ? 1 : 0
  rest_api_id = var.rest_api_id
  parent_id   = var.root_resource_id
  path_part   = local.split_path[0]
}

resource "aws_api_gateway_method" "method" {
  rest_api_id      = var.rest_api_id
  resource_id      = local.resource_id
  http_method      = var.http_method
  authorization    = local.custom_auth == true ? "CUSTOM" : "NONE"
  authorizer_id    = local.custom_auth == true ? var.custom_authorizer_id : ""
  api_key_required = local.custom_auth != true && var.use_api_key == true

  request_parameters = local.is_proxy ? {
    "method.request.path.proxy" = true
  } : {}
}

resource "aws_api_gateway_resource" "item" {
  count       = local.clean_path != "" ? 1 : 0
  rest_api_id = var.rest_api_id
  parent_id   = local.parent_id
  path_part   = local.child_path
}

resource "aws_api_gateway_integration" "integration" {
  rest_api_id = var.rest_api_id
  resource_id = local.resource_id
  http_method = aws_api_gateway_method.method.http_method

  # Included because of this issue: https://github.com/hashicorp/terraform/issues/10501
  integration_http_method = var.http_method
  passthrough_behavior = "WHEN_NO_MATCH"

  type = "AWS"

  # See uri description: https://docs.aws.amazon.com/apigateway/api-reference/resource/integration/
  uri         = "arn:aws:apigateway:${var.region}:s3:path/${local.bucket_name}/${local.s3_key}"
  credentials = var.iam_role_arn

  request_parameters = local.is_proxy ? {
    "integration.request.path.proxy" = "method.request.path.proxy"
  } : { }

  content_handling = var.image_host ? "CONVERT_TO_BINARY" : null
}

resource "aws_api_gateway_integration_response" "ok" {
  depends_on = [aws_api_gateway_integration.integration]

  rest_api_id = var.rest_api_id
  resource_id = local.resource_id
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
  resource_id = local.resource_id
  http_method = aws_api_gateway_method.method.http_method
  status_code = 200

  response_parameters = {
    "method.response.header.Timestamp"      = true
    "method.response.header.Content-Length" = true
    "method.response.header.Content-Type"   = true
  }
}

resource "aws_api_gateway_method_settings" "settings" {
  count       = var.cache && local.has_parent ? 1 : 0 # Only deploy if cache override specified
  rest_api_id = var.rest_api_id
  stage_name  = var.stage_name
  method_path = "${var.path}/${var.http_method}"

  settings {
    metrics_enabled      = true
    logging_level        = var.env == "prod" ? "ERROR" : "INFO"
    caching_enabled      = var.cache
    cache_ttl_in_seconds = 300
  }
}
