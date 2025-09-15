output "instance_public_ip" {
  value = aws_eip.app_server_eip.public_ip
}

output "instance_dns_name" {
  value = aws_route53_record.app_dns.fqdn
}

output "php_app_url" {
  value = "https://${aws_route53_record.app_dns.fqdn}/"
}

output "grafana_url" {
  value = "https://${aws_route53_record.app_dns.fqdn}:3000"
}

output "kibana_url" {
  value = "https://${aws_route53_record.app_dns.fqdn}:5601"
}

output "logstash_url" {
  value = "https://${aws_route53_record.app_dns.fqdn}:5044"
}

output "elasticsearch_url" {
  value = "https://${aws_route53_record.app_dns.fqdn}:9200"
}
