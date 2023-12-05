output "bastion_public_ip" {
  value = aws_instance.bastion.public_ip
}

output "bastion_private_ip" {
  value = aws_instance.bastion.private_ip
}

output "web_server_private_ips" {
  value = aws_instance.web_server[*].private_ip
}

output "alb_sg_id" {
  value = aws_security_group.alb_sg.id
}

output "web_server_instance_ids" {
  value = aws_instance.web_server[*].id
}
