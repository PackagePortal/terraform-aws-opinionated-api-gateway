resource "aws_cloudwatch_log_group" "logs" {
  name              = "API-Gateway-Execution-Logs_${aws_api_gateway_rest_api.rest_api.id}/${local.name_base}"
  retention_in_days = 7
}

resource "aws_api_gateway_method_settings" "settings" {
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  stage_name  = aws_api_gateway_stage.stage.stage_name
  method_path = "*/*" # Logs all apis

  settings {
    metrics_enabled = true
    logging_level   = var.env == "prod" ? "ERROR" : "INFO"
  }
}