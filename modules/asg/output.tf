output "asg_names" {
  description = "The names of the Auto Scaling Groups."
  value       = aws_autoscaling_group.example_asg[*].name
}

output "asg_arns" {
  description = "The ARNs of the Auto Scaling Groups."
  value       = aws_autoscaling_group.example_asg[*].arn
}

output "launch_config_ids" {
  description = "The IDs of the Launch Configurations used by the Auto Scaling Groups."
  value       = aws_launch_configuration.example_lc[*].id
}
