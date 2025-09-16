variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "eu-north-1"
}

variable "public_key" {
  description = "SSH public key for EC2 instance"
  type        = string
}
#без явного указания ID образа почему-то не работает. 
variable "instance_ami" {
  description = "AMI ID for EC2 instance"
  type        = string
  default     = "ami-091a5ee0157d25e3f"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.medium"
}

variable "ec2_ssh_public_key" {
  description = "Public SSH key for EC2 access"
  type        = string
}

variable "ec2_private_key" {
  description = "Private key for EC2 SSH access"
  type        = string
  sensitive   = true
}
