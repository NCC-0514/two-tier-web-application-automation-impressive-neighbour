# Define the provider
provider "aws" {
  region = "us-east-1"
}

# Data source for AMI id
data "aws_ami" "latest_amazon_linux" {
  owners      = ["amazon"]
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# Use remote state to retrieve the data
data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket = "impressive-neighbours-staging"
    key    = "network/terraform.tfstate"
    region = "us-east-1"
  }
}

# Data source for availability zones in us-east-1
data "aws_availability_zones" "available" {
  state = "available"
}

# Define tags locally
locals {
  default_tags = merge(
    var.default_tags,
    { "Env" = var.env }
  )
  name_prefix = "${var.prefix}-${var.env}"
}

# Launch Configuration for the ASG
resource "aws_launch_configuration" "webserver_lc" {
  name_prefix   = "${local.name_prefix}-lc-"
  image_id      = data.aws_ami.latest_amazon_linux.id
  instance_type = lookup(var.instance_type, var.env)
  key_name      = aws_key_pair.web_key.key_name
  security_groups = [aws_security_group.web_sg.id]

  lifecycle {
    create_before_destroy = true
  }
}

# Auto Scaling Group
resource "aws_autoscaling_group" "webserver_asg" {
  launch_configuration    = aws_launch_configuration.webserver_lc.id
  vpc_zone_identifier     = data.terraform_remote_state.network.outputs.private_subnet_ids
  max_size                = var.asg_max_size
  min_size                = var.asg_min_size
  desired_capacity        = var.asg_desired_capacity
  health_check_type       = "EC2"
  force_delete            = true
  target_group_arns       = [aws_lb_target_group.web_tg.arn]
  tag {
    key                 = "Name"
    value               = "${local.name_prefix}-webserver"
    propagate_at_launch = true
  }
}

# Target Group for the Load Balancer
resource "aws_lb_target_group" "web_tg" {
  name     = "${local.name_prefix}-web-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.terraform_remote_state.network.outputs.vpc_id

  health_check {
    interval            = 30
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

# Security Group for Web Server Instances
resource "aws_security_group" "web_sg" {
  name        = "${local.name_prefix}-web-sg"
  description = "Security group for web server instances"
  vpc_id      = data.terraform_remote_state.network.outputs.vpc_id

dynamic "ingress" {
    for_each = var.service_ports
    content {
      from_port       = ingress.value
      to_port         = ingress.value
      security_groups = [aws_security_group.bastion_sg.id, aws_security_group.alb_sg.id]
      protocol        = "tcp"
    }
}

# Explicitly allow incoming traffic on ports 80 (HTTP) and 443 (HTTPS) from the ALB
  ingress {
    from_port       = 80
    to_port         = 80
    security_groups = [aws_security_group.alb_sg.id]
    protocol        = "tcp"
  }

  ingress {
    from_port       = 443
    to_port         = 443
    security_groups = [aws_security_group.alb_sg.id]
    protocol        = "tcp"
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = merge(local.default_tags,
    {
      "Name" = "${local.name_prefix}-sg"
    }
  )
}

  # Explicitly allow incoming traffic on ports 80 (HTTP) and 443 (HTTPS) from the ALB
  ingress {
    from_port       = 80
    to_port         = 80
    security_groups = [aws_security_group.alb_sg.id]
    protocol        = "tcp"
  }

  ingress {
    from_port       = 443
    to_port         = 443
    security_groups = [aws_security_group.alb_sg.id]
    protocol        = "tcp"
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = merge(local.default_tags,
    {
      "Name" = "${local.name_prefix}-sg"
    }
  )
}

# Security Group for Bastion Host
resource "aws_security_group" "bastion_sg" {
  name        = "${local.name_prefix}-bastion-sg"
  description = "Security group for Bastion host"
  vpc_id      = data.terraform_remote_state.network.outputs.vpc_id

  # Ingress and Egress Rules for Bastion Host
  ingress {
    description = "SSH from private IP of CLoud9 machine"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = merge(local.default_tags,
    {
      "Name" = "${local.name_prefix}-bastion-sg"
    }
  )
}

# SSH Key Pair for EC2 Instances
resource "aws_key_pair" "web_key" {
  key_name   = local.name_prefix
  public_key = file(var.public_key_path)
}