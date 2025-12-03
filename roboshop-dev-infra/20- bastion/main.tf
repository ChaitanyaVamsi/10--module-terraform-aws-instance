resource "aws_instance" "example" {
  ami                    = local.ami_id
  instance_type          = "t3.micro"
  vpc_security_group_ids = [local.bastion_sg_id] # here we are linking by id , everytime a resource is created it also creates id, arn ,owner_id, tags_all
  subnet_id              = local.public_subnet_id
  # iam_instance_profile   = aws_iam_instance_profile.bastion.name #first time
  iam_instance_profile = "bastion_profile"

  # need more for terraform
  root_block_device {
    volume_size = 50
    volume_type = "gp3" # or "gp2", depending on your preference
  }

  user_data = file("bastion.sh")
  tags = merge(local.common_tags, {
    Name = "${var.project_name} - ${var.environment} - bastion host"
  })
}


# resource "aws_iam_instance_profile" "bastion" { # frist timme no error
#   name = "bastion_profile"
#   role = "bastionTerraformAdmin" // // The IAM role is created manually. We attach it to the Bastion instance profile.
# }
