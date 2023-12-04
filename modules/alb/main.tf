# Local variables
locals {
  default_tags = merge(
    var.default_tags,
    { "Env" = var.env }
  )
  name_prefix = "${var.prefix}-${var.env}"
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

# Use remote state to retrieve the data
data "terraform_remote_state" "web_server" {
  backend = "s3"
  config = {
    bucket = "impressive-neighbours-staging"
    key    = "webserver/terraform.tfstate"
    region = "us-east-1"
  }
}

# Data source for an existing security group (alb_sg)
data "aws_security_group" "existing_sg" {
  name = "alb_sg"
  vpc_id = data.terraform_remote_state.network.outputs.vpc_id
}

# ALB Configuration
resource "aws_lb" "web_alb" {
  name               = "${var.alb_name_prefix}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [data.aws_security_group.existing_sg.id]

  enable_deletion_protection = false

  subnets = [
    data.terraform_remote_state.network.outputs.public_subnet_ids[0],
    data.terraform_remote_state.network.outputs.public_subnet_ids[1],
    data.terraform_remote_state.network.outputs.public_subnet_ids[2],
  ]

  tags = merge(
    local.default_tags,
    {
      Name = "${local.name_prefix}-alb"
    }
  )
}

# Target Group for ALB
resource "aws_lb_target_group" "web_tg" {
  count    = length(data.terraform_remote_state.web_server.outputs.web_server_instance_ids)
  name     = "${var.alb_name_prefix}-tg-${count.index}"
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.terraform_remote_state.network.outputs.vpc_id

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    interval            = 30
    path                = "/"
    protocol            = "HTTP"
  }

  tags = merge(
    local.default_tags, {
      Name = "${local.name_prefix}-tg-${count.index}"
    }
  )
}

# Associate target instances with target groups
resource "aws_lb_target_group_attachment" "web_tg_attachment" {
  count             = length(data.terraform_remote_state.web_server.outputs.web_server_instance_ids)
  target_group_arn  = aws_lb_target_group.web_tg[count.index].arn
  target_id         = data.terraform_remote_state.web_server.outputs.web_server_instance_ids[count.index]
}


# Listener for ALB
resource "aws_lb_listener" "web_front_end" {
  load_balancer_arn = aws_lb.web_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_tg[0].arn
  }

  tags = merge(
    local.default_tags, {
      Name = "${local.name_prefix}-front_end"
    }
  )
}
