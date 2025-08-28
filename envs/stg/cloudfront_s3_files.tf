resource "aws_s3_bucket" "files" {
  bucket = "${local.name_prefix}-files"
  tags   = local.tags
}

resource "aws_s3_bucket_ownership_controls" "files_owership" {
  bucket = aws_s3_bucket.files.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}
resource "aws_s3_bucket_acl" "files_bucket_acl" {
  #Must have frist or error
  depends_on = [aws_s3_bucket_ownership_controls.files_owership]

  bucket = aws_s3_bucket.files.id
  acl    = "private"
}

resource "aws_s3_bucket_cors_configuration" "files_file_cors" {
  bucket = aws_s3_bucket.files.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "HEAD", "PUT", "POST", "DELETE"]
    allowed_origins = ["*"]
    expose_headers  = []
  }
}

data "aws_iam_policy_document" "files_distribute" {
  statement {
    sid    = "AllowCloudFrontServicePrincipalReadWrite"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    actions = [
      "s3:GetObject",
      "s3:PutObject"
    ]

    resources = ["${aws_s3_bucket.files.arn}/*"]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = ["${aws_cloudfront_distribution.files_distributions.arn}"]
    }
  }
}

resource "aws_s3_bucket_policy" "allow_files_distribute" {
  bucket = aws_s3_bucket.files.id
  policy = data.aws_iam_policy_document.files_distribute.json
}

################################################################

# #OAC
resource "aws_cloudfront_origin_access_control" "files_oac" {
  name                              = "${local.name_prefix}-files-oac"
  description                       = "files s3 oac"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "files_distributions" {
  #Default s3 origin
  origin {
    domain_name              = aws_s3_bucket.files.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.files_oac.id
    origin_id                = aws_s3_bucket.files.bucket_regional_domain_name
  }
  #Alb origin
  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "/"
#   aliases             = [var.files_domain]

#   logging_config {
#     include_cookies = false
#     bucket          = "${local.name_prefix}-service-logs.s3.amazonaws.com"
#     prefix          = "files/"
#   }
  default_cache_behavior {
    allowed_methods            = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods             = ["GET", "HEAD"]
    target_origin_id           = aws_s3_bucket.files.bucket_regional_domain_name
    compress                   = true
    cache_policy_id            = var.cache_optimzied_id
    viewer_protocol_policy     = "redirect-to-https"
  }

  price_class = "PriceClass_All"
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
  tags = local.tags
#   viewer_certificate {
#     cloudfront_default_certificate = false
#     acm_certificate_arn            = var.acm_certificate_arn_global
#     minimum_protocol_version       = "TLSv1.2_2021"
#     ssl_support_method             = "sni-only"
#   }
    viewer_certificate {
        cloudfront_default_certificate = true
    }
}