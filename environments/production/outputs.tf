output "vpc_id" {
  description = "VPC ID"
  value       = module.networking.vpc_id
}

output "alb_dns_name" {
  description = "ALB DNS name"
  value       = module.ecs.alb_dns_name
}

output "cloudfront_domain" {
  description = "CloudFront distribution domain"
  value       = module.cdn.distribution_domain_name
}

output "ecr_repository_url" {
  description = "ECR repository URL for CI/CD"
  value       = module.build.ecr_repository_url
}

output "database_endpoint" {
  description = "Aurora writer endpoint"
  value       = module.database.cluster_endpoint
  sensitive   = true
}

output "redis_endpoint" {
  description = "Redis primary endpoint"
  value       = module.cache.primary_endpoint_address
  sensitive   = true
}

output "ecs_cluster_name" {
  description = "ECS cluster name"
  value       = module.ecs.cluster_name
}

output "ecs_service_name" {
  description = "ECS service name"
  value       = module.ecs.service_name
}

output "name_servers" {
  description = "Route53 name servers — update your domain registrar with these"
  value       = module.dns.name_servers
}

output "waf_web_acl_arn" {
  description = "WAF web ACL ARN for the CloudFront distribution"
  value       = module.cdn.waf_web_acl_arn
}
