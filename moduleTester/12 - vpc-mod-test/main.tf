module "samplecheck_vpc" {
  source       = "../../11 -  module-terraform-aws-vpc"
  vpc_cidr     = var.vpc_cidr
  project_name = var.project_name
  environment  = var.environment
  vpc_tags     = var.vpc_tags
  #public subnets
  public_subent_cidrs = var.public_subent_cidrs
  #private subnet
  private_subent_cidrs = var.private_subnet_cidrs
  #database subnet
  database_subent_cidrs = var.database_subnet_cidrs
  # vpc peering with default
  is_peering_required = false // by default this value is true , if it is false it will delte vpc  peering
}
