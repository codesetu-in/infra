output "distribution_id" {
  description = "CloudFront distribution ID"
  value       = aws_cloudfront_distribution.main.id
}

output "distribution_arn" {
  description = "CloudFront distribution ARN"
  value       = aws_cloudfront_distribution.main.arn
}

output "distribution_domain_name" {
  description = "CloudFront distribution domain name"
  value       = aws_cloudfront_distribution.main.domain_name
}

output "distribution_hosted_zone_id" {
  description = "Route53 hosted zone ID for the CloudFront distribution"
  value       = aws_cloudfront_distribution.main.hosted_zone_id
}

output "waf_web_acl_arn" {
  description = "WAF web ACL ARN"
  value       = aws_wafv2_web_acl.main.arn
}

output "waf_web_acl_id" {
  description = "WAF web ACL ID"
  value       = aws_wafv2_web_acl.main.id
}

output "cloudfront_certificate_arn" {
  description = "ACM certificate ARN used by CloudFront (us-east-1)"
  value       = aws_acm_certificate_validation.cloudfront.certificate_arn
}
