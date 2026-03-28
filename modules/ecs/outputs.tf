output "cluster_id" {
  description = "ECS cluster ID"
  value       = aws_ecs_cluster.main.id
}

output "cluster_name" {
  description = "ECS cluster name"
  value       = aws_ecs_cluster.main.name
}

output "cluster_arn" {
  description = "ECS cluster ARN"
  value       = aws_ecs_cluster.main.arn
}

output "service_id" {
  description = "ECS service ID"
  value       = aws_ecs_service.main.id
}

output "service_name" {
  description = "ECS service name"
  value       = aws_ecs_service.main.name
}

output "task_definition_arn" {
  description = "Latest task definition ARN"
  value       = aws_ecs_task_definition.main.arn
}

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = aws_lb.main.dns_name
}

output "alb_arn" {
  description = "ARN of the Application Load Balancer"
  value       = aws_lb.main.arn
}

output "alb_arn_suffix" {
  description = "ARN suffix of the ALB for use in CloudWatch metrics"
  value       = aws_lb.main.arn_suffix
}

output "alb_zone_id" {
  description = "Route53 hosted zone ID of the ALB"
  value       = aws_lb.main.zone_id
}

output "target_group_arn" {
  description = "ARN of the ALB target group"
  value       = aws_lb_target_group.main.arn
}

output "target_group_arn_suffix" {
  description = "ARN suffix of the target group for use in CloudWatch metrics"
  value       = aws_lb_target_group.main.arn_suffix
}

output "log_group_name" {
  description = "CloudWatch log group name for ECS tasks"
  value       = aws_cloudwatch_log_group.main.name
}

output "task_execution_role_arn" {
  description = "ARN of the ECS task execution IAM role"
  value       = aws_iam_role.task_execution.arn
}

output "task_role_arn" {
  description = "ARN of the ECS task IAM role"
  value       = aws_iam_role.task.arn
}
