resource "aws_instance" "mongodb" {
  ami                    = local.ami_id
  instance_type          = "t3.micro"
  vpc_security_group_ids = [local.mongodb_sg_id] # here we are linking by sg_id
  subnet_id              = local.database_subnet_id
  tags = merge(local.common_tags, {
    Name = "${local.common_name_prefix}-mongodb"
  })



}

# https://developer.hashicorp.com/terraform/language/resources/terraform-data

resource "terraform_data" "mongodb" {
  triggers_replace = [
    aws_instance.mongodb.id
  ]

  connection {
    type     = "ssh"
    user     = "ec2-user" #  appropriate user for your AMI
    password = "DevOps321"
    host     = aws_instance.mongodb.private_ip
  }

  # terraform copies this file to mongodb server
  provisioner "file" {
    source      = "bootstrap.sh"
    destination = "/tmp/bootstrap.sh"
  }
  provisioner "remote-exec" {
    inline = [
      "sudo chmod +x /tmp/bootstrap.sh",
      "sudo sh /tmp/bootstrap.sh"
    ]
  }
}

#this should be run from bastion, install terraform on bastiono
#https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli
