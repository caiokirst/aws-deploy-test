output "wazuh_instance_id" {
  description = "ID of the Wazuh EC2 instance for SSM access"
  value       = aws_instance.wazuh_server.id
}

output "vpc_id" {
  description = "ID of the created VPC"
  value       = aws_vpc.main.id
}