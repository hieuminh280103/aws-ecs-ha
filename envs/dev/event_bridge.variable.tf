variable "event_bridge_config" {
  default = {
    flexible_time_window = "OFF"
    batch_1_sechule_expression = "cron(0 2 1 * ? *)" //Demo run every 2AM
    schedule_expression_timezone = "Asia/Saigon"
    task_count = 1
    assign_public_ip = false
  }
}