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
  provisioner "remote-exec" { // any code added here we need to taint this , ony then changes will be applied, terraform taint - terraform taint terraform_data.mongodb
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

  # terraform copies this file to redis server
  provisioner "file" {
    source      = "bootstrap.sh"
    destination = "/tmp/bootstrap.sh"
  }
  provisioner "remote-exec" { // any code added here we need to taint this , ony then changes will be applied
    inline = [
      "sudo chmod +x /tmp/bootstrap.sh",
      "sudo sh /tmp/bootstrap.sh redis"
    ]
  }
}

# =============================end of redis================================================

# we are creating rabbitmq private server in database subnet this is private subent

resource "aws_instance" "rabbitmq" {
  ami                    = local.ami_id
  instance_type          = "t3.micro"
  vpc_security_group_ids = [local.rabbitmq_sg_id] # here we are attaching the rabbitmq security group ID which we already created
  subnet_id              = local.database_subnet_id
  tags = merge(local.common_tags, {
    Name = "${local.common_name_prefix}-rabbitmq" # roboshop-dev-rabbitmq
  })
}


resource "terraform_data" "rabbitmq" {
  triggers_replace = [
    aws_instance.rabbitmq.id
  ]

  connection {
    type     = "ssh"
    user     = "ec2-user" #  appropriate user for your AMI
    password = "DevOps321"
    host     = aws_instance.rabbitmq.private_ip
  }

  # terraform copies this file to rabbitmq server
  provisioner "file" {
    source      = "bootstrap.sh"
    destination = "/tmp/bootstrap.sh"
  }
  provisioner "remote-exec" { // any code added herer we need to taint this , ony then changes will be applied
    inline = [
      "sudo chmod +x /tmp/bootstrap.sh",
      "sudo sh /tmp/bootstrap.sh rabbitmq"
    ]
  }
}
# =============================end of rabbitmq================================================


# we are creating mysql private server in database subnet this is private subent
resource "aws_instance" "mysql" {
  ami                    = local.ami_id
  instance_type          = "t3.micro"
  vpc_security_group_ids = [local.mysql_sg_id] # here we are attaching the mysql security group ID which we already created
  subnet_id              = local.database_subnet_id
  iam_instance_profile   = aws_iam_instance_profile.mysql.name //data.aws_iam_instance_profile.mysql.name

  tags = merge(local.common_tags, {
    Name = "${local.common_name_prefix}-mysql" # roboshop-dev-mysql
  })
}

# attaching a role for roboshop-dev-mysql instance
# refer : https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile

resource "aws_iam_instance_profile" "mysql" {
  name = "mysql_profile"
  role = "EC2-SSM-Parameter-read" // this role is maually created we are just attching this to mysql instance profile
}
# data "aws_iam_instance_profile" "mysql" {
#   name = "mysql"
# }

resource "terraform_data" "mysql" {
  triggers_replace = [
    aws_instance.mysql.id
  ]

  connection {
    type     = "ssh"
    user     = "ec2-user" #  appropriate user for your AMI
    password = "DevOps321"
    host     = aws_instance.mysql.private_ip
  }

  # terraform copies this file to mysql server
  provisioner "file" {
    source      = "bootstrap.sh"
    destination = "/tmp/bootstrap.sh"
  }
  provisioner "remote-exec" { // any code added herer we need to taint this , ony then changes will be applied
    inline = [
      "sudo chmod +x /tmp/bootstrap.sh",
      "sudo sh /tmp/bootstrap.sh mysql dev" // dev param is for mysql-main.yaml
    ]
  }
}

resource "aws_route53_record" "mongodb" {
  zone_id         = var.zone_id
  name            = "mongodb-${var.environment}.${var.domain_name}" # mongodb-dev.cloudops.store
  type            = "A"
  ttl             = 300
  records         = [aws_instance.mongodb.private_ip]
  allow_overwrite = true
}

resource "aws_route53_record" "redis" {
  zone_id         = var.zone_id
  name            = "redis-${var.environment}.${var.domain_name}" # redis-dev.cloudops.store
  type            = "A"
  ttl             = 300
  records         = [aws_instance.redis.private_ip]
  allow_overwrite = true
}


resource "aws_route53_record" "mysql" {
  zone_id         = var.zone_id
  name            = "mysql-${var.environment}.${var.domain_name}" # mysql-dev.cloudops.store
  type            = "A"
  ttl             = 300
  records         = [aws_instance.mysql.private_ip]
  allow_overwrite = true
  depends_on      = [aws_instance.mysql]
}

resource "aws_route53_record" "rabbitmq" {
  zone_id         = var.zone_id
  name            = "rabbitmq-${var.environment}.${var.domain_name}" # rabbitmq-dev.cloudops.store
  type            = "A"
  ttl             = 300
  records         = [aws_instance.rabbitmq.private_ip]
  allow_overwrite = true
}
