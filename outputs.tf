output "instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = module.ec2_instance.public_ip
}

output "aws_public_dns" {
  description = "Public DNS name of the EC2 instance"
  value       = module.ec2_instance.public_dns
}

output "php_app_url" {
  description = "URL для PHP-приложения"
  value       = "https://${module.ec2_instance.public_dns}/"
}

output "grafana_url" {
  description = "URL для Grafana"
  value       = "https://${module.ec2_instance.public_dns}:3000"
}

output "kibana_url" {
  description = "URL для Kibana"
  value       = "https://${module.ec2_instance.public_dns}:5601"
}

output "logstash_url" {
  description = "URL для Logstash"
  value       = "https://${module.ec2_instance.public_dns}:5044"
}

output "elasticsearch_url" {
  description = "URL для Elasticsearch"
  value       = "https://${module.ec2_instance.public_dns}:9200"
}

output "letsencrypt_status" {
  description = "LetsEncrypt сертификат будет получен для DNS-имени"
  value       = "Сертификат будет автоматически получен для: ${module.ec2_instance.public_dns}"
}

output "state_bucket_name" {
  description = "S3 bucket name for Terraform state"
  value       = aws_s3_bucket.terraform_state.bucket
}

output "vpc_id" {
  description = "ID созданного VPC"
  value       = module.vpc.vpc_id
}
