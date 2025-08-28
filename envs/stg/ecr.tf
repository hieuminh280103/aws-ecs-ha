#backend
resource "aws_ecr_repository" "ecr_backend" {
  name = "${local.name_prefix}-${var.ecr_backend.name}"
  image_tag_mutability = var.ecr_backend.image_tag_mutability

  image_scanning_configuration {
    scan_on_push = var.ecr_backend.scan_on_push
  }
  tags = local.tags
}

resource "aws_ecr_lifecycle_policy" "ecr_backend" {
  repository = aws_ecr_repository.ecr_backend.id
  policy = jsonencode(var.ecr_backend.lifecycle_policy)
}

resource "aws_ecr_repository" "ecr_frontend" {
  name = "${local.name_prefix}-${var.ecr_frontend.name}"
  image_tag_mutability = var.ecr_frontend.image_tag_mutability

  image_scanning_configuration {
    scan_on_push = var.ecr_frontend.scan_on_push
  }
  tags = local.tags
}

resource "aws_ecr_lifecycle_policy" "ecr_frontend" {
  repository = aws_ecr_repository.ecr_frontend.id
  policy = jsonencode(var.ecr_frontend.lifecycle_policy)
}

resource "aws_ecr_repository" "ecr_doc" {
  name = "${local.name_prefix}-${var.ecr_doc.name}"
  image_tag_mutability = var.ecr_doc.image_tag_mutability

  image_scanning_configuration {
    scan_on_push = var.ecr_doc.scan_on_push
  }
  tags = local.tags
}

resource "aws_ecr_lifecycle_policy" "ecr_doc" {
  repository = aws_ecr_repository.ecr_doc.id
  policy = jsonencode(var.ecr_doc.lifecycle_policy)
}
  