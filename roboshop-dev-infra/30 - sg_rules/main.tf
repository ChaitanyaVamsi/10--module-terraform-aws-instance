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
  security_group_id        = local.mongodb_sg_id // this is for mongodb security group
  source_security_group_id = local.bastion_sg_id
  from_port                = 22
  protocol                 = "tcp"
  to_port                  = 22
}

resource "aws_security_group_rule" "redis_bastion" {
  type                     = "ingress"
  security_group_id        = local.redis_sg_id // this is for redis security group
  source_security_group_id = local.bastion_sg_id
  from_port                = 22
  protocol                 = "tcp"
  to_port                  = 22
}
