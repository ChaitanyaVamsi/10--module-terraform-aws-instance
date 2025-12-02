#frontend accepting traffic from frontend alb
resource "aws_security_group_rule" "frontend_frontend_alb" {
  type                     = "ingress"
  security_group_id        = local.backend_alb_sg_id // this is backend_alb refer the sg-variable.tf
  source_security_group_id = local.bastion_sg_id
  from_port                = 80
  protocol                 = "tcp"
  to_port                  = 80
}


resource "aws_security_group_rule" "bastion_connection" {
  type              = "ingress"
  security_group_id = local.bastion_sg_id // this is for bastion security group
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 22
  protocol          = "tcp"
  to_port           = 22
}

resource "aws_security_group_rule" "mongodb_bastion" {
  type                     = "ingress"
  security_group_id        = local.mongodb_sg_id // this is for mongodb security group we allow traffic from bastion sg
  source_security_group_id = local.bastion_sg_id
  from_port                = 22
  protocol                 = "tcp"
  to_port                  = 22
}

resource "aws_security_group_rule" "redis_bastion" {
  type                     = "ingress"
  security_group_id        = local.redis_sg_id // this is for redis security group we allow traffic from bastion sg
  source_security_group_id = local.bastion_sg_id
  from_port                = 22
  protocol                 = "tcp"
  to_port                  = 22
}

resource "aws_security_group_rule" "rabbitmq_bastion" {
  type                     = "ingress"
  security_group_id        = local.rabbitmq_sg_id // this is for rabbitmq security group we allow traffic from bastion sg
  source_security_group_id = local.bastion_sg_id
  from_port                = 22
  protocol                 = "tcp"
  to_port                  = 22
}

resource "aws_security_group_rule" "mysql_bastion" {
  type                     = "ingress"
  security_group_id        = local.mysql_sg_id // this is for rabbitmq security group we allow traffic from bastion sg
  source_security_group_id = local.bastion_sg_id
  from_port                = 22
  protocol                 = "tcp"
  to_port                  = 22
}

resource "aws_security_group_rule" "catalogue_bastion" {
  type                     = "ingress"
  security_group_id        = local.catalogue_sg_id // this is for catalogue security group we allow traffic from bastion sg
  source_security_group_id = local.bastion_sg_id
  from_port                = 22
  protocol                 = "tcp"
  to_port                  = 22
}

resource "aws_security_group_rule" "mongdb_catalogue" { // enable this sg only then catalogue connect to mongodb other wise errro
  type                     = "ingress"
  security_group_id        = local.mongodb_sg_id // this is for mongodb security group we allow traffic from catalogue sg
  source_security_group_id = local.catalogue_sg_id
  from_port                = 27017
  protocol                 = "tcp"
  to_port                  = 27017
}
