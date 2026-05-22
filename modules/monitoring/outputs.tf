output "action_group_id" {
  description = "Monitor Action Group resource ID"
  value       = azurerm_monitor_action_group.email.id
}

output "cpu_alert_id" {
  description = "CPU utilization metric alert resource ID"
  value       = azurerm_monitor_metric_alert.api_cpu.id
}

output "memory_alert_id" {
  description = "Memory utilization metric alert resource ID"
  value       = azurerm_monitor_metric_alert.api_memory.id
}
