output "replication_group_id" {
  description = "ElastiCache replication group ID"
  value       = aws_elasticache_replication_group.main.id
}

output "replication_group_arn" {
  description = "ElastiCache replication group ARN"
  value       = aws_elasticache_replication_group.main.arn
}

output "primary_endpoint_address" {
  description = "Primary endpoint for writes"
  value       = aws_elasticache_replication_group.main.primary_endpoint_address
}

output "reader_endpoint_address" {
  description = "Reader endpoint for reads (available when num_cache_clusters >= 2)"
  value       = aws_elasticache_replication_group.main.reader_endpoint_address
}

output "port" {
  description = "Port the Redis cluster listens on"
  value       = aws_elasticache_replication_group.main.port
}

output "auth_token_secret_arn" {
  description = "ARN of the Secrets Manager secret containing the Redis AUTH token"
  value       = aws_secretsmanager_secret.redis_auth.arn
}
