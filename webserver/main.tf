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
    bucket = "acs-project-in"       // Bucket from where to GET Terraform State
    key    = "impressive-neighbour-prod-network/terraform.tfstate" // Object name in the bucket to GET Terraform State
    region = "us-east-1"                         // Region where bucket created
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
resource "aws_instance" "bastion" {
  ami                         = data.aws_ami.latest_amazon_linux.id
  instance_type               = lookup(var.instance_type, var.env)
  key_name                    = aws_key_pair.web_key.key_name
  subnet_id                   = data.terraform_remote_state.network.outputs.public_subnet_ids[0]
  security_groups             = [aws_security_group.bastion_sg.id]
  associate_public_ip_address = false
  
  
  user_data = templatefile("${path.module}/install_httpd.sh.tpl",
    {
      env    = upper(var.env),
      prefix = upper(local.name_prefix)
    }
  )
  
  root_block_device {
    encrypted = var.env == "prod" ? true : false
  }

   lifecycle {
    create_before_destroy = true
  }
  

  tags = merge(local.default_tags,
    {
      "Name" = "${local.name_prefix}-bastion-instance"
    }
  )
}


resource "aws_instance" "web_server" {
  count                       = 3
  ami                         = data.aws_ami.latest_amazon_linux.id
  instance_type               = lookup(var.instance_type, var.env)
  key_name                    = aws_key_pair.web_key.key_name
  subnet_id                   = data.terraform_remote_state.network.outputs.private_subnet_ids[count.index]
  security_groups             = [aws_security_group.web_server_sg[count.index].id]

  associate_public_ip_address = false
  
  user_data = templatefile("${path.module}/install_httpd.sh.tpl",
    {
      env    = upper(var.env),
      prefix = upper(local.name_prefix)
    }
  )
  
  root_block_device {
    encrypted = var.env == "prod" ? true : false
  }

   lifecycle {
    create_before_destroy = true
  }
  
  tags = merge(local.default_tags,
    {
      "Name" = "${local.name_prefix}-web-server-${count.index}"
    }
  )
}

# Adding SSH key to Amazon EC2
resource "aws_key_pair" "web_key" {
  key_name   = local.name_prefix
  public_key = file("${local.name_prefix}.pub")
}

# Security Group for Bastion host
resource "aws_security_group" "bastion_sg" {
  name        = "bastionvm1_sg"
  description = "Allow TLS inbound traffic"
  vpc_id      = data.terraform_remote_state.network.outputs.vpc_id

  dynamic "ingress" {
    for_each = var.service_ports
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]

    }
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

resource "aws_security_group" "web_server_sg" {
  count       = 3
  name        = "web-server-sg-${count.index}"
  description = "Allow TLS inbound traffic"
  vpc_id      = data.terraform_remote_state.network.outputs.vpc_id

  dynamic "ingress" {
    for_each = var.service_ports
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
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
      "Name" = "${local.name_prefix}-web-server-sg-${count.index}"
    }
  )
}
