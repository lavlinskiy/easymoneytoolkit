output "instance_public_ip" {
  value = aws_eip.app_server_eip.public_ip
}

output "instance_public_dns" {
  value = aws_instance.app_server.public_dns
}

output "php_app_url" {
  value = "https://${aws_instance.app_server.public_dns}/"
}

output "grafana_url" {
  value = "https://${aws_instance.app_server.public_dns}:3000"
}

output "kibana_url" {
  value = "https://${aws_instance.app_server.public_dns}:5601"
}

output "logstash_url" {
  value = "https://${aws_instance.app_server.public_dns}:5044"
}

output "elasticsearch_url" {
  value = "https://${aws_instance.app_server.public_dns}:9200"
}
