locals {
    name_prefix = "${var.project}-${var.country}-${var.environment}"
    tags = {
        Project = var.project
        Env = var.environment
        CreateBy = "terraform"
    }
}
