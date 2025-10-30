locals {
  name_prefix = "${var.project}-${var.env}"
}

module "vpc" {
  source             = "../../modules/vpc"
  name_prefix        = local.name_prefix
  az_count           = 2
  cidr_block         = "10.0.0.0/16"
  public_subnet_cidrs  = ["10.0.1.0/24","10.0.2.0/24"]
  private_subnet_cidrs = ["10.0.11.0/24","10.0.12.0/24"]
}

module "security" {
  source       = "../../modules/security"
  name_prefix  = local.name_prefix
  vpc_id       = module.vpc.vpc_id
  alb_ingress_cidrs = ["0.0.0.0/0"]
  app_port     = 3000
  db_port      = 3306
}

module "s3" {
  source      = "../../modules/s3"
  name_prefix = local.name_prefix
}

module "ecr" {
  source      = "../../modules/ecr"
  name_prefix = local.name_prefix
  repo_name   = "${local.name_prefix}-product-api"
}

module "iam" {
  source        = "../../modules/iam"
  name_prefix   = local.name_prefix
  ecr_repo_arn  = module.ecr.repo_arn
  s3_bucket_arn = module.s3.bucket_arn
}

module "rds" {
  source              = "../../modules/rds"
  name_prefix         = local.name_prefix
  vpc_id              = module.vpc.vpc_id
  private_subnet_ids  = module.vpc.private_subnet_ids
  db_username         = var.db_username
  db_password         = var.db_password
  db_sg_id            = module.security.db_sg_id
}

module "alb" {
  source               = "../../modules/alb"
  name_prefix          = local.name_prefix
  vpc_id               = module.vpc.vpc_id
  public_subnet_ids    = module.vpc.public_subnet_ids
  alb_sg_id            = module.security.alb_sg_id
  app_port             = 3000
}

module "asg_blue" {
  source                = "../../modules/asg"
  name_prefix           = local.name_prefix
  color                 = "blue"
  vpc_id                = module.vpc.vpc_id
  private_subnet_ids    = module.vpc.private_subnet_ids
  app_sg_id             = module.security.app_sg_id
  target_group_arn      = module.alb.tg_blue_arn
  instance_type         = var.instance_type
  desired_capacity      = var.active_color == "blue" ? var.desired_capacity_active : var.desired_capacity_inactive
  iam_instance_profile  = module.iam.instance_profile
  ecr_repo_url          = module.ecr.repo_url
  container_image_tag   = var.container_image_tag
  app_port              = 3000
}

module "asg_green" {
  source                = "../../modules/asg"
  name_prefix           = local.name_prefix
  color                 = "green"
  vpc_id                = module.vpc.vpc_id
  private_subnet_ids    = module.vpc.private_subnet_ids
  app_sg_id             = module.security.app_sg_id
  target_group_arn      = module.alb.tg_green_arn
  instance_type         = var.instance_type
  desired_capacity      = var.active_color == "green" ? var.desired_capacity_active : var.desired_capacity_inactive
  iam_instance_profile  = module.iam.instance_profile
  ecr_repo_url          = module.ecr.repo_url
  container_image_tag   = var.container_image_tag
  app_port              = 3000
}

output "alb_dns_name"  { value = module.alb.alb_dns_name }
output "active_color"  { value = var.active_color }
output "ecr_repo_url"  { value = module.ecr.repo_url }
output "listener_arn"  { value = module.alb.listener_arn }
output "tg_blue_arn"   { value = module.alb.tg_blue_arn }
output "tg_green_arn"  { value = module.alb.tg_green_arn }
