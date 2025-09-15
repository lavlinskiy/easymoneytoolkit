variable "ami" {
  description = "AMI ID for EC2 instance"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID for EC2 instance"
  type        = string
}

variable "security_group_ids" {
  description = "Security Group IDs for EC2 instance"
  type        = list(string)
}

variable "public_key" {
  description = "Static SSH public key for EC2 instance (deployer)"
  type        = string
}

variable "ec2_ssh_public_key" {
  description = "Public SSH key for EC2 access"
  type        = string
}

variable "ec2_private_key" {
  description = "Private SSH key for EC2 access"
  type        = string
  sensitive   = true
}

# Новые переменные для Elastic IP и DNS
variable "route53_zone_id" {
  description = "ID Route53 Hosted Zone для создания записи DNS"
  type        = string
}

variable "app_dns_name" {
  description = "DNS имя для приложения (например, app.example.com)"
  type        = string
}
