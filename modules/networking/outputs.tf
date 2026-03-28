output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "vpc_cidr_block" {
  description = "VPC CIDR block"
  value       = aws_vpc.main.cidr_block
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "IDs of the private (app) subnets"
  value       = aws_subnet.private[*].id
}

output "database_subnet_ids" {
  description = "IDs of the isolated database subnets"
  value       = aws_subnet.database[*].id
}

output "nat_gateway_ids" {
  description = "IDs of the NAT gateways"
  value       = aws_nat_gateway.main[*].id
}

output "alb_security_group_id" {
  description = "Security group ID for the Application Load Balancer"
  value       = aws_security_group.alb.id
}

output "ecs_task_security_group_id" {
  description = "Security group ID for ECS Fargate tasks"
  value       = aws_security_group.ecs_tasks.id
}

output "database_security_group_id" {
  description = "Security group ID for Aurora PostgreSQL"
  value       = aws_security_group.database.id
}

output "redis_security_group_id" {
  description = "Security group ID for ElastiCache Redis"
  value       = aws_security_group.redis.id
}
