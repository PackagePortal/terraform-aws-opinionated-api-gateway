# terraform-aws-opinionated-api-gateway

This is an opinionated terraform module that creates an API Gateway that can do one or all of a few tasks:
1. Proxy HTTP Requests
2. Integrate with SNS
3. VPC Link
4. Integrate with S3 to serve content
5. Proxy Lambda functions

## Limitations

There are some limitations that you have to accept when using this module:

1. Proxies are only supported at root (`{proxy+}`) or one resource level deep (`/path/{proxy+}`)
2. Non-proxy paths are only supported one level deep (`/do-something`)
3. Any authorization not handled by a proxy or that is not a static api key in the header requires a custom auth lambda
4. Authorization Lambda can only be deployed from an S3 bucket created outside of this module.
5. Only one api key is supported
6. SNS integrations cannot be at the root level (they are POST only - module and API gateway will not support)

Note that proxies are smart and will ignore siblings - e.g.:
```
/{proxy+}
/parent/{proxy+}
/parent/child/{proxy+}
```
are all valid at the same time. Specific takes precedence over root.

## Usage

### Prequisites

1. Route 53 zone created outside of terraform for the domain you want to use
2. If not using AWS as DNS provider, add name servers in Route 53 hosted zone to your DNS provider under NS records for
   the domain or subdomain. For example: `NS my-cool-app. <collection of assigned aws name servers>`

Here is an annotated example:

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
  # Lambda proxy
  {
      type: "lambda"
      path: "lambda/{proxy+}",
      method: "ANY",
      arn: aws_lambda.my_lambda.invoke_arn,
      name: aws_lambda.my_lambda.name,
      use_api_key: false
  }
  ]
}
```
