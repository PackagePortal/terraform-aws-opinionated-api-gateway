#################################
# Api Gateway Lambda Invoke     #
#################################
locals {
  statement_id_suffix = local.is_sub_path ? local.path_parts[0] : "root-path"
  statement_id        = "${local.name_base}-lambda-invoke-${local.statement_id_suffix}"
}

resource "aws_lambda_permission" "lambda_permission" {
  statement_id  = local.statement_id
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_name
  principal     = "apigateway.amazonaws.com"

  # The /*/*/* part allows invocation from any stage, method and resource path
  # within API Gateway REST API.
  source_arn = "${var.execution_arn}/${var.stage_name}/ANY/${var.path}"
}
