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
  description = "Public SSH key for EC2 access (used for aws_key_pair.this)"
  type        = string
}

variable "ec2_private_key" {
  description = "Private SSH key for EC2 access (used in provisioners)"
  type        = string
  sensitive   = true
}
