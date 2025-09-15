# Создаём ключ EC2 из статичного public_key
resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = var.public_key
}

resource "aws_key_pair" "this" {
  key_name   = "ec2-key"
  public_key = var.ec2_ssh_public_key
}

# EC2 инстанс
resource "aws_instance" "app_server" {
  ami                         = var.ami
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = var.security_group_ids
  key_name                    = aws_key_pair.this.key_name
  associate_public_ip_address = false  # IP через Elastic IP
  user_data                   = file("${path.module}/../../user_data/init_ec2.sh")

  tags = {
    Name = "PHP-Nginx-ELK-Grafana"
  }
}

# Elastic IP
resource "aws_eip" "app_server_eip" {
  vpc = true
}

# Ассоциация Elastic IP с EC2
resource "aws_eip_association" "app_server_assoc" {
  instance_id   = aws_instance.app_server.id
  allocation_id = aws_eip.app_server_eip.id
}

# Provisioners для копирования файлов внутрь EC2 через Elastic IP
resource "null_resource" "provision_files" {
  depends_on = [aws_eip_association.app_server_assoc]

  provisioner "file" {
    source      = "${path.module}/../../app/index.php"
    destination = "/tmp/index.php"
    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = var.ec2_private_key
      host        = aws_eip.app_server_eip.public_ip
    }
  }

  provisioner "file" {
    source      = "${path.module}/../../app/default.conf"
    destination = "/tmp/default.conf"
    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = var.ec2_private_key
      host        = aws_eip.app_server_eip.public_ip
    }
  }

  provisioner "file" {
    source      = "${path.module}/../../app/logstash.conf"
    destination = "/tmp/logstash.conf"
    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = var.ec2_private_key
      host        = aws_eip.app_server_eip.public_ip
    }
  }
}
