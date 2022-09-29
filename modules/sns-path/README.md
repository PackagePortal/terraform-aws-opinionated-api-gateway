## Resources

| Name | Type |
|------|------|
| [aws_api_gateway_integration.integration](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_integration) | resource |
| [aws_api_gateway_integration_response.integration_response](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_integration_response) | resource |
| [aws_api_gateway_method.method](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_method) | resource |
| [aws_api_gateway_method_response.ok](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_method_response) | resource |
| [aws_api_gateway_resource.path_root](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_resource) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_app_name"></a> [app\_name](#input\_app\_name) | Self-descriptive | `string` | n/a | yes |
| <a name="input_custom_authorizer_id"></a> [custom\_authorizer\_id](#input\_custom\_authorizer\_id) | Custom authorizer id for path | `string` | `""` | no |
| <a name="input_env"></a> [env](#input\_env) | Environment this is deployed in (e.g. dev or prod) | `string` | n/a | yes |
| <a name="input_http_method"></a> [http\_method](#input\_http\_method) | HTTP method for integration | `string` | `"POST"` | no |
| <a name="input_iam_role_arn"></a> [iam\_role\_arn](#input\_iam\_role\_arn) | Gateway IAM role | `string` | n/a | yes |
| <a name="input_iam_role_name"></a> [iam\_role\_name](#input\_iam\_role\_name) | IAM role name | `string` | n/a | yes |
| <a name="input_path"></a> [path](#input\_path) | Path from root of gateway | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | AWS Region gateway is deployed in | `string` | n/a | yes |
| <a name="input_rest_api_id"></a> [rest\_api\_id](#input\_rest\_api\_id) | Rest API this path is attached to | `string` | n/a | yes |
| <a name="input_root_resource_id"></a> [root\_resource\_id](#input\_root\_resource\_id) | Root api gateway path resource | `string` | n/a | yes |
| <a name="input_sns_topic_arn"></a> [sns\_topic\_arn](#input\_sns\_topic\_arn) | Arn of sns bucket to attach to | `string` | n/a | yes |
| <a name="input_use_api_key"></a> [use\_api\_key](#input\_use\_api\_key) | Whether to use custom api key | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_redeployment_trigger_json"></a> [redeployment\_trigger\_json](#output\_redeployment\_trigger\_json) | n/a |
