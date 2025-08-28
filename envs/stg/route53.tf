resource "aws_route53_zone" "private_zone" {
  name = var.private_domain

  vpc {
    vpc_id = module.vpc.vpc_id
  }
}

resource "aws_route53_record" "redis-record" {
    zone_id = aws_route53_zone.private_zone.id
    name = "${var.redis_domain}"
    type = "CNAME"
    ttl = 300
    records = ["${aws_elasticache_replication_group.redis_cluster.configuration_endpoint_address}"]
}