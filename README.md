# terraform-aws-opinionated-api-gateway

This is an opinionated Terraform module that creates an API Gateway V1 that can do one or all of the following tasks:
1. Proxy HTTP Requests
2. Integrate with SNS by dumping a request into SNS as JSON
3. VPC Link
4. Integrate with S3 to serve content
5. Proxy HTTP Lambda functions

See Limitations for tradeoffs that make this module easy to configure, and reference for a full list of created resources.

## Limitations

There are some limitations traded for ease of use detailed here:

1. Proxies are only supported at root (`{proxy+}`) or one resource level deep (`/path/{proxy+}`)
2. Non-proxy paths are only supported one level deep (`/do-something` is supported but not `/do/something`)
3. Any authorization not handled by a proxy or that is not a static api key in the header requires a custom auth lambda
4. Authorization Lambda can only be deployed from an S3 bucket created outside of this module.
5. Only one api key is supported
6. SNS integrations cannot be at the root level (they are POST only - module and API gateway will not support)
7. Right now we only have one stage deployed (you can add more outside of the module). Using more than one can be useful
for having staging environments.

Note that proxies are smart and will ignore siblings. Given these two paths:
```
/{proxy+}
/parent/{proxy+}
```
The created gateway will consider both valid at the same time. Specific takes precedence over root. So `/some-other-path`
will go to the root proxy, but `/parent/some-other-path` will go to `/parent/{proxy}`.

## Usage

### Prequisites

1. Route 53 zone created outside of terraform for the domain you want to use
2. If not using AWS as DNS provider, add name servers in Route 53 hosted zone to your DNS provider under NS records for
   the domain or subdomain. For example: `NS my-cool-app. <collection of assigned aws name servers>`
3. Terraform and the AWS provider installed, as well as an active AWS account.

Deploying this may incur costs in AWS depending on your usage of the free tiers in AWS.

### Annontated Example

```hcl-terraform
module "example" {
  source = "github.com/PackagePortal/terraform-aws-opinionated-api-gateway?ref=v0.0.1"

  name   = "example-gateway"
  env    = "prod"
  domain = "prod.my-gateway.info" # Optional, expects Route53 DNS zone to have been created for it
  region = "us-west-1" # Note that certificates MUST be created in us-east for domains that use edge CDN (module handles)
  
  # Optional variables needed for auth lambda deployment
  auth_lambda_s3_bucket = "my-bucket"
  auth_lambda_s3_key    = "some-code.zip"
  
  # See https://docs.aws.amazon.com/apigateway/latest/developerguide/apigateway-use-lambda-authorizer.html for the
  # different values here. These are passed to the authorization lambda.
  custom_auth_identity_source = "method.request.header.authorization"

  mappings = [
  ########################################
  # Proxying
  ########################################
  # All requests to none of the other paths go to the root proxy serving web page via NLB -> ALB link
  {
    type: "proxy"
    path: "{proxy+}"
    method: "ANY"
    arn: "arn"
  },
  # POST requests to /get-token will go to this endpoint using custom auth
  {
    type: "proxy"
    path: "get-token"
    method: "POST"
    use_custom_auth: true # Uses custom auth lambda for auth
    endpoint: "https://my-api.com/some/really/gross/api/path"
  },
  # VPC link path - different app handles requests to this subpath
  {
    type: "proxy"
    path: "vpc/{proxy+}"
    method: "ANY"
    arn: "arn"
  }
  ########################################
  # SNS
  ########################################
  # POST body will go to SNS if it is JSON or form url encoded
  {
    type: "sns"
    path: "update"
    method: "POST"
    arn: "arn://us-west-1:topic_name"
  },
  ########################################
  # S3
  ########################################
  # Root resouce mapping an index.html file for requests to root url
  {
    type: "s3"
    path: "",
    method: "GET",
    arn: aws_s3_bucket.resources_bucket.arn,
    key: "index.html"
  },
  # s3 assets bucket - /assets/item will return an asset (e.g. static image or webpage)
  {
    type: "s3"
    path: "assets/{proxy+}"
    method: "GET"
    use_api_key: true # Uses an API key in x-api-key for auth
    arn: "arn://us-west-1:s3-bucket-path",
    cache: true # This will cache responses from here
    image_hosting: true # Forces return of binary content for images
  },
  # S3 Bucket at root to serve static content that is not the default route, e.g. url/resource
  {
      type: "s3"
      path: "{proxy+}",
      method: "GET",
      arn: aws_s3_bucket.resources_bucket.arn
  },
  ########################################
  # Lambda Integration
  ########################################
  # Lambda proxy
  {
      type: "lambda"
      path: "lambda/{proxy+}",
      method: "ANY",
      arn: aws_lambda.my_lambda.invoke_arn,
      name: aws_lambda.my_lambda.name,
      use_api_key: false
  }
  # Lambda proxy as root resource
  {
      type: "lambda"
      path: "/",
      method: "ANY",
      arn: aws_lambda.my_lambda.invoke_arn,
      name: aws_lambda.my_lambda.name,
      use_api_key: false
  }
  ]
}
```

## Reference

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_lambda_integrations" ></a> [lambda\_integrations](modules/lambda-integration/README.md) | ./modules/lambda-integration | n/a |
| <a name="module_proxy_integrations"></a> [proxy\_integrations](modules/proxy/README.md) | ./modules/proxy | n/a |
| <a name="module_s3_integrations"></a> [s3\_integrations](modules/s3-path/README.md) | ./modules/s3-path | n/a |
| <a name="module_sns_integrations"></a> [sns\_integrations](modules/sns-path/README.md) | ./modules/sns-path | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_acm_certificate.certificate](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate) | resource |
| [aws_acm_certificate_validation.certificate](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate_validation) | resource |
| [aws_api_gateway_api_key.api_key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_api_key) | resource |
| [aws_api_gateway_authorizer.authorizer](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_authorizer) | resource |
| [aws_api_gateway_base_path_mapping.gateway](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_base_path_mapping) | resource |
| [aws_api_gateway_deployment.api_gateway_deployment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_deployment) | resource |
| [aws_api_gateway_domain_name.domain](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_domain_name) | resource |
| [aws_api_gateway_method_settings.settings](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_method_settings) | resource |
| [aws_api_gateway_rest_api.rest_api](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_rest_api) | resource |
| [aws_api_gateway_stage.stage](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_stage) | resource |
| [aws_api_gateway_usage_plan.usage](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_usage_plan) | resource |
| [aws_api_gateway_usage_plan_key.usage_plan_key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_usage_plan_key) | resource |
| [aws_cloudwatch_log_group.logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_iam_policy.kms](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.lambda_invoke](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.lambda_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.log_publishing](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.s3_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.sns_publishing](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.api_gateway_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.kms](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.lambda_invoke](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.lambda_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.log_publishing_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.s3_attach](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.sns_publishing_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_lambda_function.custom_authorizer](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function) | resource |
| [aws_route53_record.a_record](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_record.certificate_validation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_iam_policy_document.kms](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.lambda_invoke](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.log_publishing](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.s3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.sns](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_route53_zone.zone](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route53_zone) | data source |
| [aws_s3_bucket_object.source](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/s3_bucket_object) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_api_description"></a> [api\_description](#input\_api\_description) | Description for API Gateway | `string` | `"API Gateway managed by terraform"` | no |
| <a name="input_auth_lambda_env"></a> [auth\_lambda\_env](#input\_auth\_lambda\_env) | Environment variables for lambda | `map(string)` | `{}` | no |
| <a name="input_auth_lambda_handler"></a> [auth\_lambda\_handler](#input\_auth\_lambda\_handler) | Method invoke signature for AWS Lambda authorizer | `string` | `"index.handler"` | no |
| <a name="input_auth_lambda_runtime"></a> [auth\_lambda\_runtime](#input\_auth\_lambda\_runtime) | Runtime for authorization lambda | `string` | `"nodejs12.x"` | no |
| <a name="input_auth_lambda_s3_bucket"></a> [auth\_lambda\_s3\_bucket](#input\_auth\_lambda\_s3\_bucket) | If using custom auth the bucket with lamdba code in it | `string` | `""` | no |
| <a name="input_auth_lambda_s3_key"></a> [auth\_lambda\_s3\_key](#input\_auth\_lambda\_s3\_key) | If using custom auth the bucket with lamdba code in it | `string` | `""` | no |
| <a name="input_cache_cluster_size"></a> [cache\_cluster\_size](#input\_cache\_cluster\_size) | Size of cache cluster | `string` | `"0.5"` | no |
| <a name="input_custom_auth_identity_source"></a> [custom\_auth\_identity\_source](#input\_custom\_auth\_identity\_source) | Where in custom auth to find the authorization header | `string` | `"method.request.header.authorization"` | no |
| <a name="input_domain"></a> [domain](#input\_domain) | Domain for custom domain | `string` | `""` | no |
| <a name="input_env"></a> [env](#input\_env) | Environment prefix added to names | `string` | n/a | yes |
| <a name="input_manual_redeploy"></a> [manual\_redeploy](#input\_manual\_redeploy) | Whether you want manual control over redeploys | `bool` | `false` | no |
| <a name="input_mappings"></a> [mappings](#input\_mappings) | Mapping objects that define paths | `list` | <pre>[<br>  {<br>    "arn": "",<br>    "cache": false,<br>    "endpoint": "",<br>    "image_hosting": false,<br>    "key": "",<br>    "method": "POST",<br>    "name": "",<br>    "path": "foo",<br>    "use_api_key": false,<br>    "use_custom_auth": false,<br>    "use_vpc_link": false<br>  }<br>]</pre> | no |
| <a name="input_name"></a> [name](#input\_name) | Name of the API gateway | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | AWS region for deplyoment - e.g. us-west-1 | `string` | n/a | yes |
| <a name="input_sub_domain"></a> [sub\_domain](#input\_sub\_domain) | Use this if your hosted zone is the whole domain | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_api_key"></a> [api\_key](#output\_api\_key) | API key needed for API Gateway Auth |
| <a name="output_auth_lambda"></a> [auth\_lambda](#output\_auth\_lambda) | Authorization Lambda |
| <a name="output_auth_lambda_iam_role"></a> [auth\_lambda\_iam\_role](#output\_auth\_lambda\_iam\_role) | Role Auth Lambda attaches to for IAM permissions |
| <a name="output_gateway_iam_role"></a> [gateway\_iam\_role](#output\_gateway\_iam\_role) | Role API Gateway attaches to for IAM permissions |
| <a name="output_invoke_url"></a> [invoke\_url](#output\_invoke\_url) | URL to invoke rest API from |
| <a name="output_root_url"></a> [root\_url](#output\_root\_url) | Root domain of api gateway with https:// prefixed |
| <a name="output_stage_arn"></a> [stage\_arn](#output\_stage\_arn) | Stage arn |
