#the time aws secret manager waits before it can delete the secret. Default 30 days
variable "recovery_window_in_days" {
  default = 0
}
