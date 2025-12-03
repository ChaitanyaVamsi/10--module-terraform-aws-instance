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

# stop instacne to take ami
resource "aws_ec2_instance_state" "stop_my_instance" {
  instance_id = aws_instance.catalogue.id
  state       = "stopped"
  depends_on  = [terraform_data.catalogue]
}

resource "aws_ami_from_instance" "create_cataogue_ami" {
  name               = "${local.common_name_prefix}-catalogueAMI"
  source_instance_id = aws_instance.catalogue.id
  depends_on         = [aws_ec2_instance_state.stop_my_instance]
  tags = merge(local.common_tags, {
    Name = "${local.common_name_prefix}-catalogue" # roboshop-dev-catalogue
  })
}

# target group https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group
resource "aws_lb_target_group" "catalogue_target_group" {
  name                 = "${local.common_name_prefix}-catAalogue" # roboshop-dev-catalogue
  port                 = 8080
  protocol             = "HTTP"
  vpc_id               = local.vpc_id
  deregistration_delay = 30 # waiting peridopo befreo deleting

  health_check {
    healthy_threshold   = 2
    interval            = 20
    matcher             = "200-299"
    path                = "/health"
    port                = "8080"
    protocol            = "HTTP"
    timeout             = 2
    unhealthy_threshold = 2
  }

}

# launch template https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_template
resource "aws_launch_template" "catalogue_launch_template" {
  name                                 = "${local.common_name_prefix}-catalogue"
  image_id                             = aws_ami_from_instance.create_cataogue_ami.id
  instance_initiated_shutdown_behavior = "terminate"

  vpc_security_group_ids = [local.catalogue_sg_id]

  # tags for instance
  tag_specifications {
    resource_type = "instance"

    tags = merge(local.common_tags, {
      Name = "${local.common_name_prefix}-catalogue" # roboshop-dev-catalogue
    })
  }

  # tags for volume of instance
  tag_specifications {
    resource_type = "volume"

    tags = merge(local.common_tags, {
      Name = "${local.common_name_prefix}-catalogue" # roboshop-dev-catalogue
    })
  }

  # tags for launch template
  tags = merge(local.common_tags, {
    Name = "${local.common_name_prefix}-catalogue" # roboshop-dev-catalogue
  })

}

# auto scaling

resource "aws_autoscaling_group" "catalogue_autoscaling" {
  name                      = "${local.common_name_prefix}-catalogue"
  max_size                  = 5
  min_size                  = 2
  health_check_grace_period = 300
  health_check_type         = "ELB"
  desired_capacity          = 1
  force_delete              = false
  launch_template {
    id      = aws_launch_template.catalogue_launch_template.id
    version = aws_launch_template.catalogue_launch_template.latest_version
  }
  vpc_zone_identifier = local.private_subnet_ids


  dynamic "tag" {
    for_each = merge(local.common_tags, {
      Name = "${local.common_name_prefix}-catalogue" # roboshop-dev-catalogue
    })
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }

  timeouts {
    delete = "15m"
  }
}

resource "aws_autoscaling_policy" "catalogue" {
  autoscaling_group_name = aws_autoscaling_group.catalogue_autoscaling.name
  name                   = "${local.common_name_prefix}-catalogue"
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = 75.0
  }
}
