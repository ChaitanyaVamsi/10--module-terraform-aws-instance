resource "aws_instance" "terra_module_sample" {
  ami                    = var.ami_id        #mandaory
  instance_type          = var.instance_type #optional
  vpc_security_group_ids = var.sg_id         #optional
  tags                   = var.ec2_tags      #optional
}
