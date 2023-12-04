output "bastion_public_ip" {
  value = aws_instance.bastion.public_ip
}
output "bastion_private_ip" {
  value = aws_instance.bastion.private_ip
}

output "web_server_public_ips" {
  value = aws_instance.web_server[*].public_ip
}

output "web_server_private_ips" {
  value = aws_instance.web_server[*].private_ip
}