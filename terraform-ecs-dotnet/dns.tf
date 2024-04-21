resource "aws_route53_zone" "creatica-demo-zone" {
  name = "creatica-demo.playground.aws.tngtech.com"
}

resource "aws_route53_zone" "aws_playground_zone" {
  name = "playground.aws.tngtech.com"
  tags = {
    "Creator" = "Organization@TNG"
  }
  tags_all = {
    "Creator" = "Organization@TNG"
  }
}

resource "aws_route53_record" "creatica-demo-zone-ns-record" {
  name    = aws_route53_zone.creatica-demo-zone.name
  records = aws_route53_zone.creatica-demo-zone.name_servers
  ttl     = "300"
  type    = "NS"
  zone_id = aws_route53_zone.aws_playground_zone.zone_id
}
