variable "redis_cluster_config" {
  default = {
    engine                      = "redis"
    engine_version              = "7.0"
    automatic_failover_enabled  = true
    description                 = "Elastic cache for User-Api"
    replication_group_id        = "Redis-cluster"
    node_type                   = "cache.t4g.micro"
    parameter_group_name        = "default.redis7.cluster.on"
    family                      = "redis7"
    port                        = 6379
    multi_az_enabled            = false
    num_node_groups             = 1 //Number of Shards
    replicas_per_node_group     = 0
    at_rest_encryption_enabled  = true
    transit_encryption_enabled  = true
    apply_immediately           = true
  }
}
variable "auth_token" {
  default = ""
}
