## Resources

| Name | Type |
|------|------|
| [aws_api_gateway_integration.integration](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_integration) | resource |
| [aws_api_gateway_integration_response.ok](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_integration_response) | resource |
| [aws_api_gateway_method.method](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_method) | resource |
| [aws_api_gateway_method_response.ok](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_method_response) | resource |
| [aws_api_gateway_method_settings.settings](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_method_settings) | resource |
| [aws_api_gateway_resource.item](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_resource) | resource |
| [aws_api_gateway_resource.path_root](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_resource) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_app_name"></a> [app\_name](#input\_app\_name) | Self-descriptive | `string` | n/a | yes |
| <a name="input_cache"></a> [cache](#input\_cache) | Whether to use custom api key | `bool` | `false` | no |
| <a name="input_custom_authorizer_id"></a> [custom\_authorizer\_id](#input\_custom\_authorizer\_id) | Custom authorizer id for path | `string` | `""` | no |
| <a name="input_env"></a> [env](#input\_env) | Environment this is deployed in (e.g. dev or prod) | `string` | n/a | yes |
| <a name="input_http_method"></a> [http\_method](#input\_http\_method) | HTTP Method for integration with S3 | `string` | `"GET"` | no |
| <a name="input_iam_role_arn"></a> [iam\_role\_arn](#input\_iam\_role\_arn) | Gateway IAM role | `string` | n/a | yes |
| <a name="input_iam_role_name"></a> [iam\_role\_name](#input\_iam\_role\_name) | IAM role name | `string` | n/a | yes |
| <a name="input_image_host"></a> [image\_host](#input\_image\_host) | Whether content should be returned as binary for hosting images | `bool` | `false` | no |
| <a name="input_key"></a> [key](#input\_key) | Default S3 key to use | `string` | `""` | no |
| <a name="input_path"></a> [path](#input\_path) | Path from root of gateway | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | AWS region this is deployed in | `string` | n/a | yes |
| <a name="input_rest_api_id"></a> [rest\_api\_id](#input\_rest\_api\_id) | Rest API this path is attached to | `string` | n/a | yes |
| <a name="input_root_resource_id"></a> [root\_resource\_id](#input\_root\_resource\_id) | Root api gateway path resource | `string` | n/a | yes |
| <a name="input_s3_bucket_arn"></a> [s3\_bucket\_arn](#input\_s3\_bucket\_arn) | Arn of s3 bucket to attach to | `string` | n/a | yes |
| <a name="input_stage_name"></a> [stage\_name](#input\_stage\_name) | AWS API gateway stage name | `string` | n/a | yes |
| <a name="input_use_api_key"></a> [use\_api\_key](#input\_use\_api\_key) | Whether to use custom api key | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_redeployment_trigger_json"></a> [redeployment\_trigger\_json](#output\_redeployment\_trigger\_json) | n/a |
