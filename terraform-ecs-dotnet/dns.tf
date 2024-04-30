resource "aws_route53_zone" "creatica-demo-zone" {
  name = "creatica-demo.playground.aws.tngtech.com"
}

resource "aws_acm_certificate" "creatica_wildcard_cert" {
  domain_name       = "creatica-demo.playground.aws.tngtech.com"
  validation_method = "DNS"

  subject_alternative_names = ["*.creatica-demo.playground.aws.tngtech.com"]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "creatica-certificates-dns-records" {
  for_each = {
    for dvo in aws_acm_certificate.creatica_wildcard_cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = aws_route53_zone.creatica-demo-zone.zone_id
}

resource "aws_acm_certificate_validation" "creatica_wildcard_cert_validation" {
  certificate_arn         = aws_acm_certificate.creatica_wildcard_cert.arn
  validation_record_fqdns = [for record in aws_route53_record.creatica-certificates-dns-records : record.fqdn]
}

resource "aws_route53_record" "lb_alias" {
  zone_id = aws_route53_zone.creatica-demo-zone.zone_id
  name    = "creatica-demo.playground.aws.tngtech.com"
  type    = "A"

  alias {
    name                   = aws_alb.application_load_balancer.dns_name
    zone_id                = aws_alb.application_load_balancer.zone_id
    evaluate_target_health = true
  }
}
