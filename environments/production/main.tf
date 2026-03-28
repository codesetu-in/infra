terraform {
  required_version = ">= 1.12.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

locals {
  environment = "production"
  name_prefix = "deploycloud"
  domain_name = "deploycloud.app"
  aws_region  = "us-east-1"

  azs = ["${local.aws_region}a", "${local.aws_region}b"]
}

provider "aws" {
  region = local.aws_region

  default_tags {
    tags = {
      Environment = local.environment
      Project     = "deploycloud"
      ManagedBy   = "terraform"
    }
  }
}

provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"

  default_tags {
    tags = {
      Environment = local.environment
      Project     = "deploycloud"
      ManagedBy   = "terraform"
    }
  }
}

# ── Networking ────────────────────────────────────────────────────────────────

module "networking" {
  source = "../../modules/networking"

  name_prefix = local.name_prefix
  environment = local.environment
  azs         = local.azs

  vpc_cidr              = "10.0.0.0/16"
  public_subnet_cidrs   = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs  = ["10.0.10.0/24", "10.0.11.0/24"]
  database_subnet_cidrs = ["10.0.20.0/24", "10.0.21.0/24"]

  # Production: one NAT per AZ for resilience
  single_nat_gateway = false
}

# ── Build (CodeBuild + ECR) ───────────────────────────────────────────────────

module "build" {
  source = "../../modules/build"

  name_prefix           = local.name_prefix
  environment           = local.environment
  ecr_repository_name   = "deploycloud/app"
  image_retention_count = 30
  compute_type          = "BUILD_GENERAL1_MEDIUM"
  build_timeout         = 30
}

# ── Database (Aurora PostgreSQL Serverless v2) ────────────────────────────────

module "database" {
  source = "../../modules/database"

  name_prefix = local.name_prefix
  environment = local.environment

  subnet_ids         = module.networking.database_subnet_ids
  security_group_ids = [module.networking.database_security_group_id]

  database_name  = "deploycloud"
  engine_version = "16.4"

  # Production: wider capacity range for traffic spikes
  min_capacity = 0.5
  max_capacity = 8

  backup_retention_period = 7
  deletion_protection     = true
  skip_final_snapshot     = false
}

# ── Cache (ElastiCache Redis) ─────────────────────────────────────────────────

module "cache" {
  source = "../../modules/cache"

  name_prefix = local.name_prefix
  environment = local.environment

  subnet_ids         = module.networking.private_subnet_ids
  security_group_ids = [module.networking.redis_security_group_id]

  engine_version = "7.1"
  node_type      = "cache.t4g.small"

  # Production: Multi-AZ with one replica for failover
  multi_az_enabled   = true
  num_cache_clusters = 2

  snapshot_retention_limit = 3
}

# ── ECS (Fargate) ─────────────────────────────────────────────────────────────

module "ecs" {
  source = "../../modules/ecs"

  name_prefix = local.name_prefix
  environment = local.environment

  vpc_id                     = module.networking.vpc_id
  public_subnet_ids          = module.networking.public_subnet_ids
  private_subnet_ids         = module.networking.private_subnet_ids
  alb_security_group_id      = module.networking.alb_security_group_id
  ecs_task_security_group_id = module.networking.ecs_task_security_group_id

  certificate_arn = module.dns.certificate_arn

  container_image   = "${module.build.ecr_repository_url}:latest"
  container_port    = 3000
  health_check_path = "/health"

  # Production: larger tasks, more replicas, broader scaling range
  task_cpu      = 1024
  task_memory   = 2048
  desired_count = 3
  min_capacity  = 2
  max_capacity  = 20

  # Smaller Spot weight for production to reduce interruption risk
  fargate_spot_weight = 2
  log_retention_days  = 90

  environment_variables = {
    NODE_ENV   = "production"
    APP_DOMAIN = local.domain_name
  }

  secrets = {
    DB_SECRET    = module.database.master_user_secret_arn
    REDIS_SECRET = module.cache.auth_token_secret_arn
  }
}

# ── DNS & Certificates ────────────────────────────────────────────────────────

module "dns" {
  source = "../../modules/dns"

  name_prefix  = local.name_prefix
  environment  = local.environment
  domain_name  = local.domain_name
  create_zone  = true
  alb_dns_name = module.ecs.alb_dns_name
  alb_zone_id  = module.ecs.alb_zone_id
}

# ── CDN (CloudFront + WAF) ────────────────────────────────────────────────────

module "cdn" {
  source = "../../modules/cdn"

  providers = {
    aws           = aws
    aws.us_east_1 = aws.us_east_1
  }

  name_prefix  = local.name_prefix
  environment  = local.environment
  alb_dns_name = module.ecs.alb_dns_name
  domain_name  = local.domain_name
  zone_id      = module.dns.zone_id

  # Production: serve from more edge locations
  price_class    = "PriceClass_All"
  waf_rate_limit = 2000
}

# ── Monitoring ────────────────────────────────────────────────────────────────

module "monitoring" {
  source = "../../modules/monitoring"

  name_prefix = local.name_prefix
  environment = local.environment

  ecs_cluster_name        = module.ecs.cluster_name
  ecs_service_name        = module.ecs.service_name
  alb_arn_suffix          = module.ecs.alb_arn_suffix
  target_group_arn_suffix = module.ecs.target_group_arn_suffix

  sns_email_endpoint   = var.alerts_email
  cpu_alarm_threshold  = 80
  error_rate_threshold = 1
}
