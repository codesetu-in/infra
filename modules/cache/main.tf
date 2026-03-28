locals {
  name_prefix = "${var.name_prefix}-${var.environment}"

  # Production needs >= 2 nodes for Multi-AZ; clamp for safety
  effective_num_clusters = var.multi_az_enabled ? max(var.num_cache_clusters, 2) : var.num_cache_clusters
}

# ── Auth token stored in Secrets Manager ─────────────────────────────────────

resource "aws_secretsmanager_secret" "redis_auth" {
  name                    = "${local.name_prefix}/redis/auth-token"
  description             = "Redis AUTH token for ${local.name_prefix}"
  recovery_window_in_days = 7
}

resource "aws_secretsmanager_secret_version" "redis_auth" {
  secret_id     = aws_secretsmanager_secret.redis_auth.id
  secret_string = random_password.redis_auth.result
}

resource "random_password" "redis_auth" {
  length           = 64
  special          = true
  # Redis auth token may only contain printable ASCII except space, double-quote, and @
  override_special = "!#$%&'()*+,-./:;<=>?[\\]^_`{|}~"
  min_upper        = 4
  min_lower        = 4
  min_numeric      = 4
}

# ── Subnet Group ─────────────────────────────────────────────────────────────

resource "aws_elasticache_subnet_group" "main" {
  name        = local.name_prefix
  description = "ElastiCache subnet group for ${local.name_prefix}"
  subnet_ids  = var.subnet_ids
}

# ── Redis Replication Group ───────────────────────────────────────────────────

resource "aws_elasticache_replication_group" "main" {
  replication_group_id = local.name_prefix
  description          = "Redis 7 for ${local.name_prefix}"

  engine_version = var.engine_version
  node_type      = var.node_type

  num_cache_clusters         = local.effective_num_clusters
  multi_az_enabled           = var.multi_az_enabled
  automatic_failover_enabled = var.multi_az_enabled

  transit_encryption_enabled = true
  at_rest_encryption_enabled = true
  auth_token                 = aws_secretsmanager_secret_version.redis_auth.secret_string

  subnet_group_name  = aws_elasticache_subnet_group.main.name
  security_group_ids = var.security_group_ids

  snapshot_retention_limit = var.snapshot_retention_limit
  maintenance_window       = var.maintenance_window

  apply_immediately = true

  lifecycle {
    ignore_changes = [auth_token]
  }
}

terraform {
  required_providers {
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}
