resource "aws_instance" "example" {
  ami                    = local.ami_id
  instance_type          = "t3.micro"
  vpc_security_group_ids = [local.bastion_sg_id] # here we are linking by id , everytime a resource is created it also creates id, arn ,owner_id, tags_all
  subnet_id              = local.public_subnet_id
  tags = merge(local.common_tags, {
    Name = "${var.project_name} - ${var.environment} - bastion host"
  })
}
