resource "aws_instance" "catalogue" {
  ami                    = local.ami_id
  instance_type          = "t3.micro"
  vpc_security_group_ids = [local.catalogue_sg_id] # here we are attaching the catalogue security group ID which we already created
  subnet_id              = local.private_subnet_id
  tags = merge(local.common_tags, {
    Name = "${local.common_name_prefix}-catalogue" # roboshop-dev-catalogue
  })
}

# connect to instance using remote-exec provisioner using terraform_data

resource "terraform_data" "catalogue" {
  triggers_replace = [
    aws_instance.catalogue.id
  ]

  connection {
    type     = "ssh"
    user     = "ec2-user" #  appropriate user for your AMI
    password = "DevOps321"
    host     = aws_instance.catalogue.private_ip
  }

  # terraform copies this file to catalogue server
  provisioner "file" {
    source      = "catalogue.sh"
    destination = "/tmp/catalogue.sh"
  }
  provisioner "remote-exec" { // any code added here we need to taint this , ony then changes will be applied, terraform taint - terraform taint terraform_data.catalogue
    inline = [
      "sudo chmod +x /tmp/catalogue.sh",
      "sudo sh /tmp/catalogue.sh catalogue ${var.environment}"
    ]
  }
}
