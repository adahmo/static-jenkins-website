output "ec2_public_ip" {
  description = "Public IP address of the DevOps EC2 server"
  value       = aws_instance.devops_server.public_ip
}

output "ssh_command" {
  description = "SSH command to connect to EC2"
  value       = var.create_key_pair ? "ssh -i ${local.generated_private_key_file} ubuntu@${aws_instance.devops_server.public_ip}" : "ssh -i <path-to-private-key> ubuntu@${aws_instance.devops_server.public_ip}"
}

output "key_pair_name" {
  description = "AWS EC2 key pair name used by the instance"
  value       = local.effective_key_name
}

output "generated_private_key_file" {
  description = "Local path of the generated private key PEM file when create_key_pair is enabled"
  value       = var.create_key_pair ? local.generated_private_key_file : null
}

output "jenkins_url" {
  description = "Jenkins dashboard URL"
  value       = "http://${aws_instance.devops_server.public_ip}:8080"
}

output "k8s_app_url" {
  description = "Health app URL exposed from k3s NodePort service"
  value       = "http://${aws_instance.devops_server.public_ip}:30080"
}

output "jenkins_initial_admin_password_command" {
  description = "Run this on EC2 to get initial Jenkins admin password"
  value       = "sudo cat /var/lib/jenkins/secrets/initialAdminPassword"
}