output "bastion_public_ip" {
  value = aws_instance.bastion.public_ip
}

output "bastion_private_ip" {
  value = aws_instance.bastion.private_ip
}

output "web_server_private_ips" {
  value = aws_instance.web_server[*].private_ip
}

output "asg_names" {
  description = "The names of the Auto Scaling Groups."
  value       = aws_autoscaling_group.web_server_asg[*].name
}

output "asg_arns" {
  description = "The ARNs of the Auto Scaling Groups."
  value       = aws_autoscaling_group.web_server_asg[*].arn
}

output "launch_config_ids" {
  description = "The IDs of the Launch Configurations used by the Auto Scaling Groups."
  value       = aws_launch_configuration.web_server_lc[*].id
}

# ALB DNS name
output "alb_dns_name" {
  value = aws_lb.web_alb.dns_name
}
