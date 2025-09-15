# ====== SSH ключи ======
resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = var.public_key
}

resource "aws_key_pair" "this" {
  key_name   = "ec2-key"
  public_key = var.ec2_ssh_public_key
}

# ====== EC2 инстанс ======
resource "aws_instance" "app_server" {
  ami                    = var.ami
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = var.security_group_ids
  key_name               = aws_key_pair.this.key_name

  # Используем Elastic IP для maildomain
  user_data = templatefile("${path.module}/../../user_data/init_ec2.sh", {
    maildomain = aws_eip.app_server_eip.public_ip
  })

  tags = {
    Name = "PHP-Nginx-ELK-Grafana"
  }
}

# ====== Elastic IP ======
resource "aws_eip" "app_server_eip" {
  vpc = true
}

# ====== Привязка EIP к инстансу ======
resource "aws_eip_association" "app_server_assoc" {
  instance_id   = aws_instance.app_server.id
  allocation_id = aws_eip.app_server_eip.id
}
