locals {
  ami_id             = data.aws_ami.joindevops.id
  catalogue_sg_id    = data.aws_ssm_parameter.catalogue_sg_id.value
  vpc_id             = data.aws_ssm_parameter.vpc_id.value
  private_subnet_id  = split(",", data.aws_ssm_parameter.private_subnet_ids.value)[0]
  private_subnet_ids = split(",", data.aws_ssm_parameter.private_subnet_ids.value)
  common_name_prefix = "${var.project_name} - ${var.environment}" #roboshop - dev
  common_tags = {
    Project     = var.project_name,
    environment = var.environment,
    terraform   = true
  }
}
