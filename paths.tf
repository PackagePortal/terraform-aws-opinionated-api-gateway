module "s3_integrations" {
  for_each = local.s3_mappings_map
  source   = "./modules/s3-path"

  rest_api_id      = aws_api_gateway_rest_api.rest_api.id
  s3_bucket_arn    = each.value.arn
  path             = each.value.path
  region           = var.region
  iam_role_arn     = aws_iam_role.api_gateway_role.arn
  iam_role_name    = aws_iam_role.api_gateway_role.name
  env              = var.env
  app_name         = var.name
  root_resource_id = aws_api_gateway_rest_api.rest_api.root_resource_id
  http_method      = each.value.method
  cache            = each.value.cache
  stage_name       = local.name_base
  image_host       = each.value.image_hosting
  key              = each.value.key

  # Optional auth vars
  custom_authorizer_id = each.value.use_custom_auth == true ? aws_api_gateway_authorizer.authorizer[0].id : ""
  use_api_key          = each.value.use_api_key
}

module "sns_integrations" {
  for_each = local.sns_mappings_map
  source   = "./modules/sns-path"

  rest_api_id      = aws_api_gateway_rest_api.rest_api.id
  sns_topic_arn    = each.value.arn
  path             = each.value.path
  iam_role_arn     = aws_iam_role.api_gateway_role.arn
  iam_role_name    = aws_iam_role.api_gateway_role.name
  region           = var.region
  env              = var.env
  app_name         = var.name
  root_resource_id = aws_api_gateway_rest_api.rest_api.root_resource_id
  http_method      = each.value.method

  # Optional auth vars
  custom_authorizer_id = each.value.use_custom_auth == true ? aws_api_gateway_authorizer.authorizer[0].id : ""
  use_api_key          = each.value.use_api_key
}

module "proxy_integrations" {
  for_each = local.proxy_mappings_map
  source   = "./modules/proxy"

  rest_api_id            = aws_api_gateway_rest_api.rest_api.id
  load_balancer_link_arn = each.value.arn
  path                   = each.value.path
  iam_role_arn           = aws_iam_role.api_gateway_role.arn
  env                    = var.env
  app_name               = var.name
  root_resource_id       = aws_api_gateway_rest_api.rest_api.root_resource_id
  endpoint               = each.value.endpoint
  cache                  = each.value.cache
  stage_name             = local.name_base

  # Optional auth vars
  custom_authorizer_id = each.value.use_custom_auth == true ? aws_api_gateway_authorizer.authorizer[0].id : ""
  use_api_key          = each.value.use_api_key
}

module "lambda_integrations" {
  for_each = local.lambda_mappings_map
  source   = "./modules/lambda-integration"

  rest_api_id       = aws_api_gateway_rest_api.rest_api.id
  path              = each.value.path
  iam_role_arn      = aws_iam_role.api_gateway_role.arn
  env               = var.env
  app_name          = var.name
  root_resource_id  = aws_api_gateway_rest_api.rest_api.root_resource_id
  lamdba_invoke_arn = each.value.arn
  cache             = each.value.cache
  lambda_name       = each.value.name
  stage_name        = local.name_base
  execution_arn     = aws_api_gateway_rest_api.rest_api.execution_arn

  # Optional auth vars
  custom_authorizer_id = each.value.use_custom_auth == true ? aws_api_gateway_authorizer.authorizer[0].id : ""
  use_api_key          = each.value.use_api_key
}
