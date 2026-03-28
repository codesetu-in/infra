output "cluster_id" {
  description = "Aurora cluster ID"
  value       = aws_rds_cluster.main.id
}

output "cluster_arn" {
  description = "Aurora cluster ARN"
  value       = aws_rds_cluster.main.arn
}

output "cluster_identifier" {
  description = "Aurora cluster identifier"
  value       = aws_rds_cluster.main.cluster_identifier
}

output "cluster_endpoint" {
  description = "Writer endpoint for the Aurora cluster"
  value       = aws_rds_cluster.main.endpoint
}

output "cluster_reader_endpoint" {
  description = "Read-only endpoint for the Aurora cluster"
  value       = aws_rds_cluster.main.reader_endpoint
}

output "cluster_port" {
  description = "Port the cluster accepts connections on"
  value       = aws_rds_cluster.main.port
}

output "database_name" {
  description = "Name of the initial database"
  value       = aws_rds_cluster.main.database_name
}

output "master_user_secret_arn" {
  description = "ARN of the Secrets Manager secret containing the master credentials"
  value       = aws_rds_cluster.main.master_user_secret[0].secret_arn
}
