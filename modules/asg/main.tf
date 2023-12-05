provider "aws" {
  region = "us-east-1"
}

# Declare the data source to fetch the latest Amazon Linux AMI
data "aws_ami" "latest_amazon_linux" {
  most_recent = true

  owners = ["amazon"]

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
    key    = "impressive-neighbour-modules-network/terraform.tfstate"
    region = "us-east-1"
  }
}

resource "aws_launch_configuration" "example_lc" {
  name_prefix       = "example-lc-"
  image_id          = var.ami_id
  instance_type     = "t3.small"  # Adjust instance type as needed

  lifecycle {
    create_before_destroy = true
  }

  # Additional configurations like security groups, user data, etc.
}

resource "aws_autoscaling_group" "example_asg" {
  desired_capacity     = 2
  max_size             = 5
  min_size             = 1
  # count removed if you want only one Auto Scaling Group
  launch_configuration = aws_launch_configuration.example_lc.id
  vpc_zone_identifier  = data.terraform_remote_state.network.outputs.private_subnet_ids # Replace with your subnet ID(s)

  health_check_type          = "EC2"
  health_check_grace_period  = 300
  force_delete               = true

  tag {
    key                 = "Name"
    value               = "example-asg-instance"
    propagate_at_launch = true
  }
}
