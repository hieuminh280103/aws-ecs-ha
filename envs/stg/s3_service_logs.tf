# resource "aws_s3_bucket" "service_logs" {
#   bucket = "${local.name_prefix}-service-logs"
#   tags   = local.tags
# }

# resource "aws_s3_object" "alb-access-logs" {
#   bucket = aws_s3_bucket.service_logs.id
#   key = "alb"
# }

# resource "aws_s3_object" "admin-frontend-access-logs" {
#   bucket = aws_s3_bucket.service_logs.id
#   key = "admin-frontend"
# }

# resource "aws_s3_object" "admin-api-access-logs" {
#   bucket = aws_s3_bucket.service_logs.id
#   key = "admin-api"
# }

# resource "aws_s3_bucket_lifecycle_configuration" "service_logs" {
#   bucket = aws_s3_bucket.service_logs.id
#   rule {
#     id = "${local.name_prefix}-service-logs"
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
# resource "aws_s3_bucket_ownership_controls" "service_logs_ownership" {
#   bucket = aws_s3_bucket.service_logs.id
#   rule {
#     object_ownership = "BucketOwnerPreferred"
#   }
# }

# resource "aws_s3_bucket_acl" "access_acl_log" {
#   depends_on = [ aws_s3_bucket_ownership_controls.service_logs_ownership ]
#   bucket = aws_s3_bucket.service_logs.id
#   acl = "private"
# }
# resource "aws_s3_bucket_public_access_block" "service_logs" {
#   bucket = aws_s3_bucket.service_logs.id

#   block_public_acls       = true
#   block_public_policy     = true
#   ignore_public_acls      = true
#   restrict_public_buckets = true
# }

# resource "aws_s3_bucket_policy" "service_logs" {
#   bucket = aws_s3_bucket.service_logs.id
#   policy = jsonencode({
#     "Version" : "2012-10-17",
#     "Statement" : [
#       {
#         "Effect" : "Allow",
#         "Principal" : {
#           "AWS" : "${data.aws_caller_identity.current.arn}" #Assume role who is reponsible
#         },
#         "Action" : "s3:PutObject",
#         "Resource" : [
#           "arn:aws:s3:::${aws_s3_bucket.service_logs.id}/*",
#         ],
#       },
#       {
#         "Effect" : "Allow",
#         "Principal" : {
#           "Service" : "delivery.logs.amazonaws.com"
#         },
#         "Action" : "s3:PutObject",
#         "Resource" : [
#           "arn:aws:s3:::${aws_s3_bucket.service_logs.id}/*",
#         ],
#         "Condition" : {
#           "StringEquals" : {
#             "s3:x-amz-acl" : "bucket-owner-full-control"
#           }
#         }
#       },
#       {
#         "Effect" : "Allow",
#         "Principal" : {
#           "Service" : "delivery.logs.amazonaws.com"
#         },
#         "Action" : "s3:GetBucketAcl",
#         "Resource" : "arn:aws:s3:::${aws_s3_bucket.service_logs.id}"
#       },
#       {
#         "Effect" : "Allow",
#         "Principal" : {
#           "AWS" : "${data.aws_elb_service_account.main.arn}"
#         },
#         "Action" : "s3:PutObject",
#         "Resource" : [
#           "arn:aws:s3:::${aws_s3_bucket.service_logs.id}/*",
#         ],
#       }
#     ]
#   })
# }
