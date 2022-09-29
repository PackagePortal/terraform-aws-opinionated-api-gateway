output "gateway_iam_role" {
  description = "Role API Gateway attaches to for IAM permissions"
  value       = aws_iam_role.api_gateway_role
}

output "auth_lambda_iam_role" {
  description = "Role Auth Lambda attaches to for IAM permissions"
  value       = aws_iam_role.lambda
}

output "auth_lambda" {
  description = "Authorization Lambda"
  value       = aws_lambda_function.custom_authorizer
}

output "api_key" {
  description = "API key needed for API Gateway Auth"
  value       = aws_api_gateway_api_key.api_key.value
}

output "invoke_url" {
  description = "URL to invoke rest API from"
  value       = "${aws_api_gateway_deployment.api_gateway_deployment.invoke_url}${local.name_base}"
}

output "root_url" {
  description = "Root domain of api gateway with https:// prefixed"
  value       = "https://${var.domain}"
}

output "stage_arn" {
  description = "Stage arn"
  value       = aws_api_gateway_stage.stage.arn
}
