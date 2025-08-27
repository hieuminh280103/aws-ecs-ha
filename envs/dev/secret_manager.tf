# Frontend SM resource
resource "aws_secretsmanager_secret" "frontend" {
  name                    = "${local.name_prefix}-secret-manager-frontend"
  recovery_window_in_days = var.recovery_window_in_days
}
# Backend SM resource
resource "aws_secretsmanager_secret" "api" {
  name                    = "${local.name_prefix}-secret-manager-api"
  recovery_window_in_days = var.recovery_window_in_days
}