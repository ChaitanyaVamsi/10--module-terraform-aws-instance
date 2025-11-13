# this is using predefined modules

# module "catalogue" {
#   source = "terraform-aws-modules/security-group/aws"

#   name        = "${local.common_name_prefix} - catalogue"
#   description = "Security group for catalogue with custom ports open within VPC, egress all traffic "
#   vpc_id      = data.aws_ssm_parameter.vpc_id.value //tells AWS which VPC to create the security group in.

# }


module "sg" {
  count          = length(var.sg_names)
  source         = "git::https://github.com/ChaitanyaVamsi/module-terraform-aws-sg.git?ref=main" // refrence form github
  project_name   = "roboshop"
  environment    = "dev"
  sg_name        = var.sg_names[count.index]
  sg_description = "created for ${var.sg_names[count.index]}"
  vpc_id         = local.vpc_id
}
