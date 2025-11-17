# this is mongo db private instance
resource "aws_instance" "mongodb" {
  ami                    = local.ami_id
  instance_type          = "t3.micro"
  vpc_security_group_ids = [local.mongodb_sg_id] # here we are attaching the mongodb security group ID which we already created
  subnet_id              = local.database_subnet_id
  tags = merge(local.common_tags, {
    Name = "${local.common_name_prefix}-mongodb" # roboshop-dev-mongodb
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
  provisioner "remote-exec" { // any code added herer we need to taint this , ony then changes will be applied
    inline = [
      "sudo chmod +x /tmp/bootstrap.sh",
      "sudo sh /tmp/bootstrap.sh mongodb"
    ]
  }
}

#this should be run from bastion, install terraform on bastiono
#https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli

# =============================end of mongodb================================================


# we are creating redis private server in database subnet this is private subent

resource "aws_instance" "redis" {
  ami                    = local.ami_id
  instance_type          = "t3.micro"
  vpc_security_group_ids = [local.redis_sg_id] # here we are attaching the redis security group ID which we already created
  subnet_id              = local.database_subnet_id
  tags = merge(local.common_tags, {
    Name = "${local.common_name_prefix}-redis" # roboshop-dev-redis
  })
}


resource "terraform_data" "redis" {
  triggers_replace = [
    aws_instance.redis.id
  ]

  connection {
    type     = "ssh"
    user     = "ec2-user" #  appropriate user for your AMI
    password = "DevOps321"
    host     = aws_instance.redis.private_ip
  }

  # terraform copies this file to mongodb server
  provisioner "file" {
    source      = "bootstrap.sh"
    destination = "/tmp/bootstrap.sh"
  }
  provisioner "remote-exec" { // any code added herer we need to taint this , ony then changes will be applied
    inline = [
      "sudo chmod +x /tmp/bootstrap.sh",
      "sudo sh /tmp/bootstrap.sh redis"
    ]
  }
}
