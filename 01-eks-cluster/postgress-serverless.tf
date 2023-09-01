data "aws_rds_engine_version" "postgresql" {
  engine  = "aurora-postgresql"
  version = "14.5"
}

module "aurora_postgresql_v2" {
source  = "terraform-aws-modules/rds-aurora/aws"

  name              = "${local.name}-postgresqlv2"
  engine            = data.aws_rds_engine_version.postgresql.engine
  engine_mode       = "provisioned"
  engine_version    = data.aws_rds_engine_version.postgresql.version
  storage_encrypted = true
  master_username   = local.db_creds.username
  master_password = local.db_creds.password

  vpc_id               = module.vpc.vpc_id
  db_subnet_group_name = module.vpc.database_subnet_group_name
  security_group_rules = {
    vpc_ingress = {
      cidr_blocks = module.vpc.private_subnets_cidr_blocks
    }
  }

  monitoring_interval = 60

  apply_immediately   = true
  skip_final_snapshot = true

  serverlessv2_scaling_configuration = {
    min_capacity = 0.5
    max_capacity = 5
  }

  instance_class = "db.serverless"
  instances = {
    one = {}
  }

  tags = local.common_tags
}

resource "kubernetes_config_map" "db_endpoint" {
  metadata {
    name = "${local.name}-postgresqlv2-endpoint"
  }

  data = {
    db-url = module.aurora_postgresql_v2.cluster_endpoint
  }
}