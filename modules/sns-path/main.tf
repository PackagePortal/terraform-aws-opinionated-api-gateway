locals {
  name_base   = "${var.env}-${var.app_name}"
  custom_auth = var.custom_authorizer_id != ""
}

resource "aws_api_gateway_resource" "path_root" {
  rest_api_id = var.rest_api_id
  parent_id   = var.root_resource_id
  path_part   = var.path
}

resource "aws_api_gateway_method" "method" {
  rest_api_id      = var.rest_api_id
  resource_id      = aws_api_gateway_resource.path_root.id
  http_method      = var.http_method
  authorization    = local.custom_auth == true ? "CUSTOM" : "NONE"
  authorizer_id    = local.custom_auth == true ? var.custom_authorizer_id : ""
  api_key_required = local.custom_auth != true && var.use_api_key == true
}

resource "aws_api_gateway_integration" "integration" {
  rest_api_id = var.rest_api_id
  resource_id = aws_api_gateway_resource.path_root.id
  http_method = aws_api_gateway_method.method.http_method

  integration_http_method = "POST"

  type            = "AWS"
  uri             = "arn:aws:apigateway:${var.region}:sns:path//"
  credentials     = var.iam_role_arn
  connection_type = "INTERNET"

  passthrough_behavior = "NEVER"

  request_parameters = {
    "integration.request.header.Content-Type" = "'application/x-www-form-urlencoded'"
  }

  request_templates = {
    "application/json" = "Action=Publish&TopicArn=$util.urlEncode('${var.sns_topic_arn}')&Message=$util.urlEncode($input.body)"
  }
}

resource "aws_api_gateway_integration_response" "integration_response" {
  depends_on = [aws_api_gateway_integration.integration]

  rest_api_id = var.rest_api_id
  resource_id = aws_api_gateway_resource.path_root.id
  http_method = aws_api_gateway_method.method.http_method
  status_code = aws_api_gateway_method_response.ok.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }

  response_templates = {
    "application/json" = ""
  }
}

resource "aws_api_gateway_method_response" "ok" {
  depends_on  = [aws_api_gateway_method.method]
  rest_api_id = var.rest_api_id
  resource_id = aws_api_gateway_resource.path_root.id
  http_method = aws_api_gateway_method.method.http_method
  status_code = 200

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
  }

  response_models = {
    "application/json" = "Empty"
  }
}
