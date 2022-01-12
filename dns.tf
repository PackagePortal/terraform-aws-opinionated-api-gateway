####################################################################################
# This file creates a certificate for a domain provided in variables.
# Note that to make it edge optimized we have to map to cloudfront which is where it
# is actually deployed internally by the API Gateway
####################################################################################

data "aws_route53_zone" "zone" {
  count        = local.has_custom_domain ? 1 : 0
  name         = local.domain_name
  private_zone = false
}

resource "aws_acm_certificate" "certificate" {
  count             = local.has_custom_domain ? 1 : 0
  domain_name       = trim(local.domain_name, ".")
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  provider = aws.east
}

resource "aws_route53_record" "certificate_validation" {
  count      = local.has_custom_domain ? 1 : 0
  depends_on = [aws_acm_certificate.certificate]
  name       = tolist(aws_acm_certificate.certificate[0].domain_validation_options)[0]["resource_record_name"]
  type       = tolist(aws_acm_certificate.certificate[0].domain_validation_options)[0]["resource_record_type"]
  zone_id    = data.aws_route53_zone.zone[0].zone_id
  records    = [tolist(aws_acm_certificate.certificate[0].domain_validation_options)[0]["resource_record_value"]]
  ttl        = 300
}

resource "aws_acm_certificate_validation" "certificate" {
  count    = local.has_custom_domain ? 1 : 0
  provider = aws.east

  certificate_arn         = aws_acm_certificate.certificate[0].arn
  validation_record_fqdns = aws_route53_record.certificate_validation.*.fqdn
}

resource "aws_api_gateway_domain_name" "domain" {
  count           = local.has_custom_domain ? 1 : 0
  certificate_arn = aws_acm_certificate_validation.certificate[0].certificate_arn
  domain_name     = trim(local.domain_name, ".")
  security_policy = "TLS_1_2"
}

resource "aws_route53_record" "a_record" {
  count   = local.has_custom_domain ? 1 : 0
  name    = aws_api_gateway_domain_name.domain[0].domain_name
  type    = "A"
  zone_id = data.aws_route53_zone.zone[0].id

  alias {
    evaluate_target_health = true
    name                   = aws_api_gateway_domain_name.domain[0].cloudfront_domain_name
    zone_id                = aws_api_gateway_domain_name.domain[0].cloudfront_zone_id
  }
}

resource "aws_api_gateway_base_path_mapping" "gateway" {
  count       = local.has_custom_domain ? 1 : 0
  api_id      = aws_api_gateway_rest_api.rest_api.id
  stage_name  = aws_api_gateway_stage.stage.stage_name
  domain_name = aws_api_gateway_domain_name.domain[0].domain_name
}
