resource "aws_iam_role" "api_gateway_role" {
  name = "${local.name_base}-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "apigateway.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
  EOF
}

data "aws_iam_policy_document" "log_publishing" {
  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
      "logs:PutLogEvents",
      "logs:GetLogEvents",
      "logs:FilterLogEvents"
    ]

    resources = ["*"]
  }
}

resource "aws_iam_policy" "log_publishing" {
  name        = "${var.env}-${local.name_base}-log-pub"
  path        = "/"
  description = "Allow publishing to cloudwach"

  policy = data.aws_iam_policy_document.log_publishing.json
}

resource "aws_iam_role_policy_attachment" "log_publishing_attachment" {
  role       = aws_iam_role.api_gateway_role.name
  policy_arn = aws_iam_policy.log_publishing.arn
}

data "aws_iam_policy_document" "kms" {
  statement {
    actions   = ["kms:*"]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "kms" {
  name        = "${var.env}-${local.name_base}-kms-key-gen"
  path        = "/"
  description = "Allow data key usage for sns encryption"

  policy = data.aws_iam_policy_document.kms.json
}

resource "aws_iam_role_policy_attachment" "kms" {
  role       = aws_iam_role.api_gateway_role.name
  policy_arn = aws_iam_policy.kms.arn
}

data "aws_iam_policy_document" "lambda_invoke" {
  count = local.needs_lambda ? 1 : 0
  statement {
    actions = [
      "lambda:InvokeFunction"
    ]

    resources = [aws_lambda_function.custom_authorizer[0].arn]
  }
}

resource "aws_iam_policy" "lambda_invoke" {
  count       = local.needs_lambda ? 1 : 0
  name        = "${var.env}-${local.name_base}-lambda-invoke"
  path        = "/"
  description = "Allow lambda invocation"

  policy = data.aws_iam_policy_document.lambda_invoke[0].json
}

resource "aws_iam_role_policy_attachment" "lambda_invoke" {
  count      = local.needs_lambda ? 1 : 0
  role       = aws_iam_role.api_gateway_role.name
  policy_arn = aws_iam_policy.lambda_invoke[0].arn
}

#################################
# Lambda IAM                    #
#################################
resource "aws_iam_role" "lambda" {
  count = local.needs_lambda ? 1 : 0
  name  = "iam_for_${local.name_base}_gateway_auth_lambda"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

# See also the following AWS managed policy: AWSLambdaBasicExecutionRole
resource "aws_iam_policy" "lambda_logs" {
  count       = local.needs_lambda ? 1 : 0
  name        = "${local.name_base}-lambda-logging"
  path        = "/"
  description = "IAM policy for logging from a lambda"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*",
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  count      = local.needs_lambda ? 1 : 0
  role       = aws_iam_role.lambda[0].name
  policy_arn = aws_iam_policy.lambda_logs[0].arn
}
