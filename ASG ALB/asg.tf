# Data source for the latest Amazon Linux AMI
data "aws_ami" "latest_amazon_linux" {
  owners      = ["amazon"]
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# Launch Configuration
resource "aws_launch_configuration" "example" {
  name_prefix     = "${local.name_prefix}-launch-config-"
  image_id        = data.aws_ami.latest_amazon_linux.id
  instance_type   = var.instance_type #  variable has to be defined in varaibles.tf

  lifecycle {
    create_before_destroy = true
  }

  # additional configurations like security groups, user data, etc.
}

# Auto Scaling Group
resource "aws_autoscaling_group" "example" {
  vpc_zone_identifier  = aws_subnet.private_subnet[*].id
  launch_configuration = aws_launch_configuration.example.id

  min_size         = var.asg_min_size #  variable has to be defined in varaibles.tf
  max_size         = var.asg_max_size #  variable has to be defined in varaibles.tf
  desired_capacity = var.asg_desired_capacity # variable has to be defined in varaibles.tf

  target_group_arns = [aws_lb_target_group.example.arn]

  tag {
    key                 = "Name"
    value               = "${local.name_prefix}-asg-instance"
    propagate_at_launch = true
  }
}

# Scaling Policies
resource "aws_autoscaling_policy" "scale_up" {
  name                   = "${local.name_prefix}-scale-up"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.example.name
}

resource "aws_autoscaling_policy" "scale_down" {
  name                   = "${local.name_prefix}-scale-down"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.example.name
}
