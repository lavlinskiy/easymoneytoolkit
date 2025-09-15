output "vpc_id" {
  description = "ID созданной VPC"
  value       = aws_vpc.main.id
}

output "public_subnet_id" {
  description = "ID публичной подсети"
  value       = aws_subnet.public.id
}
