output "public_subnet_ids" {
  value = aws_subnet.public_subnet[*].id
}

output "vpc_id" {
  value = aws_vpc.main.id
}

output "private_subnet_ids" {
  value = aws_subnet.private_subnet[*].id
}

# ALB DNS name
output "alb_dns_name" {
  value = aws_lb.example.dns_name
}

# ASG name
output "asg_name" {
  value = aws_autoscaling_group.example.name
}