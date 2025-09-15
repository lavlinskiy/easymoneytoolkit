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
  associate_public_ip_address = false

  # User data будет выполнен внутри инстанса при старте
  user_data = data.template_file.init_ec2.rendered

  tags = {
    Name = "PHP-Nginx-ELK-Grafana"
  }

  # Provisioners для копирования файлов внутрь EC2 через SSH
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

# Elastic IP
resource "aws_eip" "app_server_eip" {
  instance = aws_instance.app_server.id
  vpc      = true
}

# Route53 запись для DNS
resource "aws_route53_record" "app_dns" {
  zone_id = var.route53_zone_id
  name    = var.app_dns_name
  type    = "A"
  ttl     = 300
  records = [aws_eip.app_server_eip.public_ip]
}

# User data с передачей maildomain
data "template_file" "init_ec2" {
  template = file("${path.module}/../../user_data/init_ec2.sh")

  vars = {
    maildomain = aws_route53_record.app_dns.fqdn
  }
}
