locals {
  name_prefix = "${var.name_prefix}-${var.environment}"
}

# ── Subnet Group ─────────────────────────────────────────────────────────────

resource "aws_db_subnet_group" "main" {
  name        = local.name_prefix
  description = "Aurora subnet group for ${local.name_prefix}"
  subnet_ids  = var.subnet_ids

  tags = { Name = "${local.name_prefix}-db-subnet-group" }
}

# ── Aurora PostgreSQL Serverless v2 ──────────────────────────────────────────

resource "aws_rds_cluster" "main" {
  cluster_identifier = local.name_prefix

  engine         = "aurora-postgresql"
  engine_mode    = "provisioned"
  engine_version = var.engine_version

  database_name                = var.database_name
  manage_master_user_password  = true

  serverlessv2_scaling_configuration {
    min_capacity = var.min_capacity
    max_capacity = var.max_capacity
  }

  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = var.security_group_ids

  backup_retention_period      = var.backup_retention_period
  preferred_backup_window      = var.preferred_backup_window
  preferred_maintenance_window = var.preferred_maintenance_window

  deletion_protection     = var.deletion_protection
  skip_final_snapshot     = var.skip_final_snapshot
  final_snapshot_identifier = var.skip_final_snapshot ? null : "${local.name_prefix}-final"

  storage_encrypted = true

  enabled_cloudwatch_logs_exports = ["postgresql"]

  lifecycle {
    ignore_changes = [availability_zones]
  }
}

# Writer instance (Serverless v2 uses db.serverless instance class)
resource "aws_rds_cluster_instance" "writer" {
  identifier         = "${local.name_prefix}-writer"
  cluster_identifier = aws_rds_cluster.main.id
  instance_class     = "db.serverless"
  engine             = aws_rds_cluster.main.engine
  engine_version     = aws_rds_cluster.main.engine_version

  db_subnet_group_name    = aws_db_subnet_group.main.name
  publicly_accessible     = false
  auto_minor_version_upgrade = true
  performance_insights_enabled = true

  preferred_maintenance_window = var.preferred_maintenance_window
}
