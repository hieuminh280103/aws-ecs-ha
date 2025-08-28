variable "ecr_backend" {
  default = {
    name                 = "backend-repo"
    image_tag_mutability = "MUTABLE"
    scan_on_push         = true
    lifecycle_policy = {
      "rules" : [
        {
          "rulePriority" : 1,
          "description" : "Keep last 1 untagged image",
          "selection" : {
            "tagStatus" : "untagged",
            "countType" : "imageCountMoreThan",
            "countNumber" : 1
          },
          "action" : {
            "type" : "expire"
          }
        },
        {
          "rulePriority" : 2,
          "description" : "Keep last 30 images",
          "selection" : {
            "tagStatus" : "any",
            "countType" : "imageCountMoreThan",
            "countNumber" : 30
          },
          "action" : {
            "type" : "expire"
          }
        }
      ]
    }
  }
}

variable "ecr_frontend" {
  default = {
    name                 = "frontend-repo"
    image_tag_mutability = "MUTABLE"
    scan_on_push         = true
    lifecycle_policy = {
      "rules" : [
        {
          "rulePriority" : 1,
          "description" : "Keep last 1 untagged image",
          "selection" : {
            "tagStatus" : "untagged",
            "countType" : "imageCountMoreThan",
            "countNumber" : 1
          },
          "action" : {
            "type" : "expire"
          }
        },
        {
          "rulePriority" : 2,
          "description" : "Keep last 30 images",
          "selection" : {
            "tagStatus" : "any",
            "countType" : "imageCountMoreThan",
            "countNumber" : 30
          },
          "action" : {
            "type" : "expire"
          }
        }
      ]
    }
  }
}

variable "ecr_doc" {
  default = {
    name                 = "doc-repo"
    image_tag_mutability = "MUTABLE"
    scan_on_push         = true
    lifecycle_policy = {
      "rules" : [
        {
          "rulePriority" : 1,
          "description" : "Keep last 1 untagged image",
          "selection" : {
            "tagStatus" : "untagged",
            "countType" : "imageCountMoreThan",
            "countNumber" : 1
          },
          "action" : {
            "type" : "expire"
          }
        },
        {
          "rulePriority" : 2,
          "description" : "Keep last 30 images",
          "selection" : {
            "tagStatus" : "any",
            "countType" : "imageCountMoreThan",
            "countNumber" : 30
          },
          "action" : {
            "type" : "expire"
          }
        }
      ]
    }
  }
}

