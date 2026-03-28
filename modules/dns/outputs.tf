output "zone_id" {
  description = "Route53 hosted zone ID"
  value       = local.zone_id
}

output "zone_name" {
  description = "Route53 hosted zone name"
  value       = local.zone_name
}

output "name_servers" {
  description = "Name servers for the hosted zone (only populated when create_zone = true)"
  value       = var.create_zone ? aws_route53_zone.main[0].name_servers : []
}

output "certificate_arn" {
  description = "ARN of the validated ACM certificate (regional, for ALB)"
  value       = aws_acm_certificate_validation.main.certificate_arn
}

output "wildcard_fqdn" {
  description = "FQDN of the wildcard DNS record"
  value       = aws_route53_record.wildcard.fqdn
}
