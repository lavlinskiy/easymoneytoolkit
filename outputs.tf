output "instance_id" {
  value = module.ec2_instance.instance_id
}

output "instance_temp_public_ip" {
  value = module.ec2_instance.instance_temp_public_ip
}

output "instance_eip" {
  value = module.ec2_instance.instance_eip
}

output "instance_public_dns" {
  value = module.ec2_instance.instance_public_dns
}
