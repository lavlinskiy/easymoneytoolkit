output "instance_public_ip" {
  description = "Elastic IP of the EC2 instance"
  value       = aws_eip.app_server_eip.public_ip
}

output "instance_public_dns" {
  description = "Public DNS assigned by AWS to the EC2 instance"
  value       = aws_instance.app_server.public_dns
}

output "php_app_url" {
  description = "URL для PHP-приложения"
  value       = "http://${aws_instance.app_server.public_dns}/"
}

output "grafana_url" {
  description = "URL для Grafana"
  value       = "http://${aws_instance.app_server.public_dns}:3000"
}

output "kibana_url" {
  description = "URL для Kibana"
  value       = "http://${aws_instance.app_server.public_dns}:5601"
}

output "logstash_url" {
  description = "URL для Logstash"
  value       = "http://${aws_instance.app_server.public_dns}:5044"
}

output "elasticsearch_url" {
  description = "URL для Elasticsearch"
  value       = "http://${aws_instance.app_server.public_dns}:9200"
}
