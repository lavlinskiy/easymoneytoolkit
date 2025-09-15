output "instance_temp_public_ip" {
  description = "Temporary public IP of EC2 instance (used by provisioner)"
  value       = aws_instance.app_server.public_ip
}

output "instance_eip" {
  description = "Elastic IP assigned to EC2 instance"
  value       = aws_eip.app_server_eip.public_ip
}

output "instance_public_dns" {
  description = "Public DNS assigned by AWS (временное, до привязки EIP)"
  value       = aws_instance.app_server.public_dns
}

output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.app_server.id
}
