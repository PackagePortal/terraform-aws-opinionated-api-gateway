module "s3_integrations" {
  count  = length(local.s3_mappings)
  source = "github.com/PackagePortal/terraform-aws-gateway-s3-path?ref=v0.1.0"

  rest_api_id      = aws_api_gateway_rest_api.rest_api.id
  s3_bucket_arn    = local.s3_mappings[count.index].arn
  path             = local.s3_mappings[count.index].path
  region           = var.region
  iam_role_arn     = aws_iam_role.api_gateway_role.arn
  iam_role_name    = aws_iam_role.api_gateway_role.name
  env              = var.env
  app_name         = var.name
  root_resource_id = aws_api_gateway_rest_api.rest_api.root_resource_id
  http_method      = local.s3_mappings[count.index].method
  cache            = local.s3_mappings[count.index].cache
  stage_name       = local.name_base
  image_host       = local.s3_mappings[count.index].image_hosting
  key              = local.s3_mappings[count.index].key

  # Optional auth vars
  custom_authorizer_id = local.s3_mappings[count.index].use_custom_auth == true ? aws_api_gateway_authorizer.authorizer[0].id : ""
  use_api_key          = local.s3_mappings[count.index].use_api_key
}

module "sns_integrations" {
  count  = length(local.sns_mappings)
  source = "github.com/PackagePortal/terraform-aws-gateway-sns-path?ref=v0.1.0"

  rest_api_id      = aws_api_gateway_rest_api.rest_api.id
  sns_topic_arn    = local.sns_mappings[count.index].arn
  path             = local.sns_mappings[count.index].path
  iam_role_arn     = aws_iam_role.api_gateway_role.arn
  iam_role_name    = aws_iam_role.api_gateway_role.name
  region           = var.region
  env              = var.env
  app_name         = var.name
  root_resource_id = aws_api_gateway_rest_api.rest_api.root_resource_id
  http_method      = local.sns_mappings[count.index].method

  # Optional auth vars
  custom_authorizer_id = local.sns_mappings[count.index].use_custom_auth == true ? aws_api_gateway_authorizer.authorizer[0].id : ""
  use_api_key          = local.sns_mappings[count.index].use_api_key
}

module "proxy_integrations" {
  count  = length(local.proxy_mappings)
  source = "github.com/PackagePortal/terraform-aws-gateway-proxy-path?ref=v0.0.1"

  rest_api_id            = aws_api_gateway_rest_api.rest_api.id
  load_balancer_link_arn = local.proxy_mappings[count.index].arn
  path                   = local.proxy_mappings[count.index].path
  iam_role_arn           = aws_iam_role.api_gateway_role.arn
  env                    = var.env
  app_name               = var.name
  root_resource_id       = aws_api_gateway_rest_api.rest_api.root_resource_id
  endpoint               = local.proxy_mappings[count.index].endpoint
  cache                  = local.proxy_mappings[count.index].cache
  stage_name             = local.name_base

  # Optional auth vars
  custom_authorizer_id = local.proxy_mappings[count.index].use_custom_auth == true ? aws_api_gateway_authorizer.authorizer[0].id : ""
  use_api_key          = local.proxy_mappings[count.index].use_api_key
}

module "lambda_integrations" {
  count  = length(local.lambda_mappings)
  source = "./modules/lambda-integration"

  rest_api_id            = aws_api_gateway_rest_api.rest_api.id
  path                   = local.lambda_mappings[count.index].path
  iam_role_arn           = aws_iam_role.api_gateway_role.arn
  env                    = var.env
  app_name               = var.name
  root_resource_id       = aws_api_gateway_rest_api.rest_api.root_resource_id
  lamdba_invoke_arn      = local.lambda_mappings[count.index].arn
  cache                  = local.lambda_mappings[count.index].cache
  lambda_name            = local.lambda_mappings[count.index].name
  stage_name             = local.name_base
  execution_arn          = aws_api_gateway_rest_api.rest_api.execution_arn

  # Optional auth vars
  custom_authorizer_id = local.lambda_mappings[count.index].use_custom_auth == true ? aws_api_gateway_authorizer.authorizer[0].id : ""
  use_api_key          = local.lambda_mappings[count.index].use_api_key
}
