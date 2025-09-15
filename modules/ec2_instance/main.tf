resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = var.public_key
}

resource "aws_key_pair" "this" {
  key_name   = "ec2-key"
  public_key = var.ec2_ssh_public_key
}

resource "aws_instance" "app_server" {
  ami                         = var.ami
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = var.security_group_ids
  key_name                    = aws_key_pair.this.key_name
  associate_public_ip_address = false
  user_data                   = file("${path.module}/../../user_data/init_ec2.sh")

  tags = { Name = "PHP-Nginx-ELK-Grafana" }
}

resource "aws_eip" "app_server_eip" {
  instance = aws_instance.app_server.id
  domain   = "vpc"
}

resource "null_resource" "provision_files" {
  depends_on = [aws_eip.app_server_eip]

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
