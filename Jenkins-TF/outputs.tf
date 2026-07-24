# -----------------------------
# EC2 Information
# -----------------------------
output "instance_id" {
  description = "Jenkins EC2 Instance ID"
  value       = aws_instance.jenkins_server.id
}

output "instance_public_ip" {
  description = "Jenkins Public IP"
  value       = aws_instance.jenkins_server.public_ip
}

output "instance_public_dns" {
  description = "Jenkins Public DNS"
  value       = aws_instance.jenkins_server.public_dns
}

# -----------------------------
# URLs
# -----------------------------
output "jenkins_url" {
  description = "Jenkins URL"
  value       = "http://${aws_instance.jenkins_server.public_ip}:8080"
}

output "sonarqube_url" {
  description = "SonarQube URL"
  value       = "http://${aws_instance.jenkins_server.public_ip}:9000"
}

# -----------------------------
# Networking
# -----------------------------
output "vpc_id" {
  value = aws_vpc.jenkins_vpc.id
}

output "subnet_id" {
  value = aws_subnet.public_subnet.id
}

output "security_group_id" {
  value = aws_security_group.jenkins_sg.id
}