locals {
  tags = {
    Project   = var.project
    Env       = var.environment
    Create_by = var.create_by
  }
}

locals {
  name_prefix = "${var.project}-${var.environment}"
}
# locals {
#   target_group_s0_arn = module.alb.target_group_arns[0]
# }

locals {
  ecs_admin_api_secret_names = [
    "APP_NAME", "APP_IMAGE_NAME", "APP_ENV", "APP_KEY", "APP_DEBUG", "APP_URL", 
    "APP_DOMAIN", "APP_PORT", "FRONTEND_LOCAL_DOMAIN", "BACKEND_LOCAL_DOMAIN", 
    "QUERY_LOG_MIN_DURATION", "LOG_CHANNEL", "LOG_LEVEL", "LOG_DIR", "DB_CONNECTION", 
    "DB_HOST", "DB_PORT", "DB_EXPOSE_PORT", "DB_DATABASE", "DB_USERNAME", "DB_PASSWORD", 
    "DB_ROOT_PASSWORD", "BROADCAST_DRIVER", "CACHE_DRIVER", "FILESYSTEM_DRIVER", 
    "QUEUE_CONNECTION", "SESSION_DRIVER", "SESSION_LIFETIME", "MEMCACHED_HOST", "REDIS_CLIENT", "REDIS_SCHEME",
    "REDIS_HOST", "REDIS_PASSWORD", "REDIS_PORT", "REDIS_EXPOSE_PORT", "MAIL_MAILER", 
    "MAIL_HOST", "MAIL_PORT", "MAIL_USERNAME", "MAIL_PASSWORD", "MAIL_ENCRYPTION", 
    "MAIL_FROM_ADDRESS", "MAIL_FROM_NAME", "#AWS_ACCESS_KEY_ID", "#AWS_SECRET_ACCESS_KEY", 
    "AWS_DEFAULT_REGION", "AWS_BUCKET", "SQS_PREFIX", "SQS_QUEUE", "PUSHER_APP_ID", 
    "PUSHER_APP_KEY", "PUSHER_APP_SECRET", "PUSHER_APP_CLUSTER", "MIX_PUSHER_APP_KEY", 
    "MIX_PUSHER_APP_CLUSTER", "ACCESS_TOKEN_EXPIRE_TIME", "JWT_TTL", "COURSES_URL_MAIL", 
    "CONTACT_URL_MAIL", "ACTIVATION_EXPIRATION_HOURS", "RESET_PASSWORD_EXPIRATION_HOURS", 
    "API_KEY", "JWT_SECRET", "JWT_ALGO", "IMAGE_DOMAIN", "DOMAIN_ACCESS_LOG_CLOUDFRONT", "DOMAIN_HLS_CLOUDFRONT", "CLOUDFRONT_KEY_PAIR_ID",
    "CLOUDFRONT_PRIVATE_KEY_PATH", "CLOUDFRONT_ACCESS_LOG_FILE_PATH", "CLOUDFRONT_EXPIRES_TIME", "CLOUDFRONT_PRIVATE_KEY"
  ]
}
locals {
  ecs_user_frontend_secret_names =[
    "API_BASE_URL"
  ]
}

locals {
  combined_private_subnets_cidr_blocks = concat(
    module.vpc.private_subnets_cidr_blocks,
    module.vpc.database_subnets_cidr_blocks
  )

  combined_private_route_table_ids = concat(
    module.vpc.private_route_table_ids,
    module.vpc.database_route_table_ids
  )
}

