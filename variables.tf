variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "eu-north-1"
}

variable "public_key" {
  description = "SSH public key for EC2 instance"
  type        = string
  default     = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQD34YJqsV026RWVKPxYeY9UippPYE8bOIXIbknpdIli/qj1YAdYWIbS9tljJdfs/pmGFZiJj2E5WMzNa96YHaH4JePNpxEH5Fm5HvT8GyzfZBWRs+6LZS8TPsuVClk9msjtR2eSysgtHIYPQ4EuZlib5BaSzD2FupTQn+ztaEYCV+4DfL6XEACoifs/Fafb/cbyQWxYLdyC/JJS8FlQceiZYvwLrfY/P+hUNgQ/iCGeEUYYCx/K3RxZFRzN7hMuwSJIX37vlPNEdL/0kD0g7hBpMCxNbr6eROViIQu8xX3hHL95U+oxGg/0n9LpLlYZPJdGTDJ/1gELoxMTHi95ZZ58no4LO99IxeDKW8C3c1ARHMVdHKi63ltOe+TvpCHX2T9CHn+OHKIgTEKz2JbXovtHPMz3AExE/6qfQWYzdgddAsbMhRGT5EArnofdPDlwG+V2Xmpl+ADRKHIJlHu+SwwYfRN7yI4HSyq/1I+YseRd4J5T5oa5mSW3q/lXP4vv/X8= lavlinskiy@master"
}

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
