output "sns_topic_arn" {
  description = "ARN of the SNS alerts topic"
  value       = aws_sns_topic.alerts.arn
}

output "sns_topic_name" {
  description = "Name of the SNS alerts topic"
  value       = aws_sns_topic.alerts.name
}

output "dashboard_name" {
  description = "CloudWatch dashboard name"
  value       = aws_cloudwatch_dashboard.main.dashboard_name
}

output "cpu_alarm_arn" {
  description = "ARN of the ECS CPU alarm"
  value       = aws_cloudwatch_metric_alarm.ecs_cpu_high.arn
}

output "alb_5xx_alarm_arn" {
  description = "ARN of the ALB 5xx rate alarm"
  value       = aws_cloudwatch_metric_alarm.alb_5xx_rate.arn
}

output "unhealthy_hosts_alarm_arn" {
  description = "ARN of the unhealthy hosts alarm"
  value       = aws_cloudwatch_metric_alarm.unhealthy_hosts.arn
}
