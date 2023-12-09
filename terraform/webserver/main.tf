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
data "terraform_remote_state" "network" { // This is to use Outputs from Remote State
  backend = "s3"
  config = {
    bucket = "impressive-neighbours-staging-komal"      // Bucket from where to GET Terraform State
    key    = "network/terraform.tfstate" // Object name in the bucket to GET Terraform State
    region = "us-east-1"                            // Region where bucket created
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


# Webserver deployment
resource "aws_instance" "web_server" {
  count                       = 3
  ami                         = data.aws_ami.latest_amazon_linux.id
  instance_type               = lookup(var.instance_type, var.env)
  key_name                    = aws_key_pair.web_key.key_name
  subnet_id                   = data.terraform_remote_state.network.outputs.private_subnet_ids[count.index]
  security_groups             = [aws_security_group.web_sg.id]
  associate_public_ip_address = false
  
  root_block_device {
  encrypted = var.env == "prod"
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(local.default_tags,
    {
      "Name" = "webserver"
    }
  )
}

# Adding SSH key to Amazon EC2
resource "aws_key_pair" "web_key" {
  key_name   = local.name_prefix
  public_key = file("${local.name_prefix}.pub")
}


# Security Group
resource "aws_security_group" "web_sg" {
  name        = "allow_http_ssh"
  description = "Allow HTTP, HTTPS, and SSH inbound traffic"
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

  ingress {
      from_port       = 80
      to_port         = 80
      security_groups = [aws_security_group.bastion_sg.id, aws_security_group.alb_sg.id]
      protocol        = "tcp"
      description     = "Allow traffic from ALB on port"
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


# Bastion deployment
resource "aws_instance" "bastion" {
  ami                         = data.aws_ami.latest_amazon_linux.id
  instance_type               = lookup(var.instance_type, var.env)
  key_name                    = aws_key_pair.web_key.key_name
  subnet_id                   = data.terraform_remote_state.network.outputs.public_subnet_ids[0]
  security_groups             = [aws_security_group.bastion_sg.id]
  associate_public_ip_address = true

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(local.default_tags,
    {
      "Name" = "bastion"
    }
  )
}

# Security Group for Bastion host
resource "aws_security_group" "bastion_sg" {
  name        = "allow_ssh"
  description = "Allow SSH inbound traffic"
  vpc_id      = data.terraform_remote_state.network.outputs.vpc_id

  ingress {
    description = "Allow SSH inbound traffic from anywhere"
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

resource "aws_security_group" "alb_sg" {
  name        = "alb security group"
  description = "Security group for ALB"
  vpc_id      = data.terraform_remote_state.network.outputs.vpc_id

  // Define ingress rules
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  // Allow traffic from any source (update as needed)
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  // Allow traffic from any source (update as needed)
  }
  
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  // Allow traffic from any source (update as needed)
  }

  // Define egress rules
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"           // Allow all outbound traffic
    cidr_blocks = ["0.0.0.0/0"]  // Allow traffic to any destination (update as needed)
  }

  // Tags for the security group
  tags = merge(
    local.default_tags,
    {
      Name = "alb_sg"
    }
  )
}

resource "aws_launch_configuration" "web_server_lc" {
  name = "web-server-lc"
  image_id = data.aws_ami.latest_amazon_linux.id
  instance_type = lookup(var.instance_type, var.env)
  key_name = aws_key_pair.web_key.key_name
  security_groups = [aws_security_group.web_sg.id]
  
  root_block_device {
    encrypted = var.env == "prod"
  }
}

resource "aws_autoscaling_group" "web_server_asg" {
  desired_capacity     = 3
  max_size             = 4
  min_size             = 3
  launch_configuration = aws_launch_configuration.web_server_lc.id
  vpc_zone_identifier  = data.terraform_remote_state.network.outputs.private_subnet_ids

  health_check_type          = "EC2"
  health_check_grace_period  = 300
  force_delete               = true

  tag {
    key                 = "Name"
    value               = "webserver"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Autoscaling Policy for Scaling Up
resource "aws_autoscaling_policy" "scale_out_policy" {
  name                   = "${var.prefix}-scale-out-policy"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.web_server_asg.name
}

# Autoscaling Policy for Scaling Down
resource "aws_autoscaling_policy" "scale_in_policy" {
  name                   = "${var.prefix}-scale-in-policy"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.web_server_asg.name

}

resource "aws_cloudwatch_metric_alarm" "high_cpu_alarm" {
  alarm_name          = "${var.prefix}-high-cpu-usage"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = 10

  alarm_actions = [aws_autoscaling_policy.scale_out_policy.arn]

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.web_server_asg.name
  }
  
   tags = merge(
    local.default_tags, {
      Name = "${local.name_prefix}-high-cpu-alarm"
    }
  )
}

resource "aws_cloudwatch_metric_alarm" "low_cpu_alarm" {
  alarm_name          = "${var.prefix}-low-cpu-usage"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = 5

  alarm_actions = [aws_autoscaling_policy.scale_in_policy.arn]

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.web_server_asg.name
  }
  
   tags = merge(
    local.default_tags, {
      Name = "${local.name_prefix}-low-cpu-alarm"
    }
  )
}

# ALB Configuration
resource "aws_lb" "web_alb" {
  name               = "${var.alb_name_prefix}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]

  enable_deletion_protection = false

  subnets = [
    data.terraform_remote_state.network.outputs.public_subnet_ids[0],
    data.terraform_remote_state.network.outputs.public_subnet_ids[1],
    data.terraform_remote_state.network.outputs.public_subnet_ids[2],
  ]
  
  enable_cross_zone_load_balancing = true

  tags = merge(
    local.default_tags,
    {
      Name = "${local.name_prefix}-alb"
    }
  )
}

# Target Group for ALB
resource "aws_lb_target_group" "web_tg" {
  name     = "${var.alb_name_prefix}-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.terraform_remote_state.network.outputs.vpc_id
  target_type = "instance"

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
      Name = "${local.name_prefix}-tg"
    }
  )
}

# Associate the web server instances with target groups
resource "aws_lb_target_group_attachment" "web_tg_attachment" {
  count             = length(aws_instance.web_server)
  target_group_arn  = aws_lb_target_group.web_tg.arn
  target_id         = aws_instance.web_server[count.index].id
}

# Listener for ALB
resource "aws_lb_listener" "web_front_end" {
  load_balancer_arn = aws_lb.web_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_tg.arn
  }

  tags = merge(
    local.default_tags, {
      Name = "${local.name_prefix}-front_end"
    }
  )
}