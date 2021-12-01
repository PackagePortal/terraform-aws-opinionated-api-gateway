data "aws_s3_bucket_object" "source" {
  count  = local.needs_lambda ? 1 : 0
  bucket = var.auth_lambda_s3_bucket
  key    = "${var.auth_lambda_s3_key}.sha256"
}

resource "aws_lambda_function" "custom_authorizer" {
  count         = local.needs_lambda ? 1 : 0
  function_name = "${local.name_base}-authorizer"
  role          = aws_iam_role.lambda[0].arn
  handler       = var.auth_lambda_handler
  s3_bucket     = var.auth_lambda_s3_bucket
  s3_key        = var.auth_lambda_s3_key
  runtime       = var.auth_lambda_runtime

  # Changes in this hash uploaded on build trigger updates
  source_code_hash = chomp(data.aws_s3_bucket_object.source[0].body)

  environment {
    variables = merge({
      API_KEY = aws_api_gateway_api_key.api_key.value
    }, var.auth_lambda_env)
  }
}

resource "aws_api_gateway_authorizer" "authorizer" {
  count                  = local.needs_lambda ? 1 : 0
  name                   = "${local.name_base}-authorizer"
  rest_api_id            = aws_api_gateway_rest_api.rest_api.id
  authorizer_uri         = aws_lambda_function.custom_authorizer[0].invoke_arn
  authorizer_credentials = aws_iam_role.api_gateway_role.arn
  type                   = "REQUEST"
  identity_source        = var.custom_auth_identity_source
}


resource "aws_api_gateway_usage_plan" "usage" {
  name = "${local.name_base}-usage-plan"

  api_stages {
    api_id = aws_api_gateway_rest_api.rest_api.id
    stage  = aws_api_gateway_stage.stage.stage_name
  }
}

resource "aws_api_gateway_usage_plan_key" "usage_plan_key" {
  key_id        = aws_api_gateway_api_key.api_key.id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.usage.id
}

resource "aws_api_gateway_api_key" "api_key" {
  name = "${local.name_base}-api-key"
}
