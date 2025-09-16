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
  associate_public_ip_address = true  # временный публичный IP для provisioner, без выделения временного адреса не заливаются файлы
#потом выполняем инициализацию всего
  user_data = file("${path.module}/../../user_data/init_ec2.sh")

  tags = { Name = "PHP-Nginx-ELK-Grafana" }

  # Provisioners для копирования файлов
  provisioner "file" {
    source      = "${path.module}/../../app/index.php"
    destination = "/tmp/index.php"
    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = var.ec2_private_key
      host        = self.public_ip
    }
  }

  provisioner "file" {
    source      = "${path.module}/../../app/default.conf"
    destination = "/tmp/default.conf"
    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = var.ec2_private_key
      host        = self.public_ip
    }
  }

  provisioner "file" {
    source      = "${path.module}/../../app/logstash.conf"
    destination = "/tmp/logstash.conf"
    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = var.ec2_private_key
      host        = self.public_ip
    }
  }
}

# Elastic IP закрепляется после создания инстанса
resource "aws_eip" "app_server_eip" {
  instance   = aws_instance.app_server.id
  domain     = "vpc"
  depends_on = [aws_instance.app_server]
}
