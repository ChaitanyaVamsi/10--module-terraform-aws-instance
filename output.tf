output "public_ip" {
  value       = aws_instance.terra_module_sample.public_ip
  description = "public ip of instace cerated"
}

output "private_ip" {
  value       = aws_instance.terra_module_sample.private_ip
  description = "private ip of instace cerated"
}
