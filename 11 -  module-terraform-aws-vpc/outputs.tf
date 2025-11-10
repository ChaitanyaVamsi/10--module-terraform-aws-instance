output "vpc_id_module" {
  value = aws_vpc.main.id

}

output "pubic_subnet_id" {
  value = aws_subnet.public[*].id
}

output "private_subnet_id" {
  value = aws_subnet.private[*].id
}

output "database_subnet_id" {
  value = aws_subnet.database[*].id
}
