locals {
    name_prefix = "${var.project}-${var.environment}"
    tags = {
        Project = var.project
        Env = var.environment
        CreateBy = "terraform"
    }
}

locals {
    vpc_configs = var.in_vpc ? [{
        vpc_id = var.vpc_id
        subnets = var.private_subnet_ids
        security_group_ids = [aws_security_group.codebuild[0].id]
    }] : []
}