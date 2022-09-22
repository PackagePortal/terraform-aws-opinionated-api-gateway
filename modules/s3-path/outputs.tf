output "redeployment_trigger_json" {
  value = jsonencode(concat([
    aws_api_gateway_method.method,
    aws_api_gateway_integration.integration,
    aws_api_gateway_integration_response.ok,
    aws_api_gateway_method_response.ok,

  ],
  aws_api_gateway_method_settings.settings,
  aws_api_gateway_resource.path_root,
  aws_api_gateway_resource.item))
}
