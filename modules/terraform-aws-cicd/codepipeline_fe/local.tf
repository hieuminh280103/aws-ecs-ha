locals {
  tags = merge(
  {
    Project = var.project
    Env = var.environment
    CreateBy = "terraform"
  },
  var.tags
  )
  name_prefix = "${var.project}-${var.environment}"
}