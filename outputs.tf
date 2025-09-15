output "instance_public_ip" {
  description = "Public IP address of the EC2 instance (Elastic IP)"
  value       = module.ec2_instance.instance_public_ip
}

output "instance_public_dns" {
  description = "Public DNS name of the EC2 instance"
  value       = module.ec2_instance.instance_public_dns
}

output "php_app_url" {
  description = "URL для PHP-приложения"
  value       = module.ec2_instance.php_app_url
}

output "grafana_url" {
  description = "URL для Grafana"
  value       = module.ec2_instance.grafana_url
}

output "kibana_url" {
  description = "URL для Kibana"
  value       = module.ec2_instance.kibana_url
}

output "logstash_url" {
  description = "URL для Logstash"
  value       = module.ec2_instance.logstash_url
}

output "elasticsearch_url" {
  description = "URL для Elasticsearch"
  value       = module.ec2_instance.elasticsearch_url
}
