# resource "aws_s3_bucket" "cicd" {
#   bucket = "${local.name_prefix}-cicd"
#   tags   = local.tags
# }

# resource "aws_s3_bucket_lifecycle_configuration" "cicd" {
#   bucket = aws_s3_bucket.cicd.id
#   rule {
#     id = "${local.name_prefix}-cicd-logs"
#     filter {
#       prefix = "/"
#       #Can filter with size
#     }
#     expiration {
#       days = var.logs_retention_day
#     }
#     status = "Enabled"
#   }
# }

# resource "aws_s3_bucket_ownership_controls" "cicd" {
#   bucket = aws_s3_bucket.cicd.id
#   rule {
#     object_ownership = "BucketOwnerPreferred"
#   }
# }

# resource "aws_s3_bucket_acl" "cicd" {
#   bucket     = aws_s3_bucket.cicd.id
#   depends_on = [aws_s3_bucket_ownership_controls.cicd]
#   acl        = "private"
# }

# resource "aws_s3_bucket_public_access_block" "cicd" {
#   bucket                  = aws_s3_bucket.cicd.id
  
#   block_public_acls       = true
#   block_public_policy     = true
#   ignore_public_acls      = true
#   restrict_public_buckets = true
# }
