## Resources

| Name | Type |
|------|------|
| [aws_api_gateway_integration.integration](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_integration) | resource |
| [aws_api_gateway_integration_response.integration_response](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_integration_response) | resource |
| [aws_api_gateway_method.method](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_method) | resource |
| [aws_api_gateway_method_response.ok](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_method_response) | resource |
| [aws_api_gateway_method_settings.settings](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_method_settings) | resource |
| [aws_api_gateway_resource.path_root](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_resource) | resource |
| [aws_api_gateway_resource.proxy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_resource) | resource |
| [aws_lambda_permission.lambda_permission](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_app_name"></a> [app\_name](#input\_app\_name) | Self-descriptive | `string` | n/a | yes |
| <a name="input_cache"></a> [cache](#input\_cache) | Whether to use custom api key | `bool` | `false` | no |
| <a name="input_custom_authorizer_id"></a> [custom\_authorizer\_id](#input\_custom\_authorizer\_id) | Custom authorizer id for path | `string` | `""` | no |
| <a name="input_env"></a> [env](#input\_env) | Environment this is deployed in (e.g. dev or prod) | `string` | n/a | yes |
| <a name="input_execution_arn"></a> [execution\_arn](#input\_execution\_arn) | Rest API Execution ARN | `string` | n/a | yes |
| <a name="input_iam_role_arn"></a> [iam\_role\_arn](#input\_iam\_role\_arn) | Gateway IAM role | `string` | n/a | yes |
| <a name="input_lambda_name"></a> [lambda\_name](#input\_lambda\_name) | Lambda name | `string` | n/a | yes |
| <a name="input_lamdba_invoke_arn"></a> [lamdba\_invoke\_arn](#input\_lamdba\_invoke\_arn) | Endpoint to proxy to if not a VPC link | `string` | n/a | yes |
| <a name="input_path"></a> [path](#input\_path) | Path from root of gateway | `string` | n/a | yes |
| <a name="input_rest_api_id"></a> [rest\_api\_id](#input\_rest\_api\_id) | Rest API this path is attached to | `string` | n/a | yes |
| <a name="input_root_resource_id"></a> [root\_resource\_id](#input\_root\_resource\_id) | Root api gateway path resource | `string` | n/a | yes |
| <a name="input_stage_name"></a> [stage\_name](#input\_stage\_name) | AWS API gateway stage name | `string` | n/a | yes |
| <a name="input_use_api_key"></a> [use\_api\_key](#input\_use\_api\_key) | Whether to use custom api key | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_redeployment_trigger_json"></a> [redeployment\_trigger\_json](#output\_redeployment\_trigger\_json) | n/a |
<!-- END_TF_DOCS -->
