variable "project_name" {
  description = "Prefix used for naming AWS resources"
  type        = string
  default     = "health-devops"
}

variable "aws_region" {
  description = "AWS region for deployment"
  type        = string
  default     = "us-east-1"
}

variable "instance_type" {
  description = "EC2 instance type. t2.medium is acceptable for this static-site lab stack; use a larger instance for Java builds or SonarQube"
  type        = string
  default     = "t2.medium"
}

variable "create_key_pair" {
  description = "Whether Terraform should generate an EC2 key pair and save the private key locally"
  type        = bool
  default     = true
}

variable "generated_key_name" {
  description = "Name to use for the generated AWS key pair when create_key_pair is true"
  type        = string
  default     = null
}

variable "private_key_output_file" {
  description = "Optional local path for the generated private key PEM file when create_key_pair is true"
  type        = string
  default     = null
}

variable "key_name" {
  description = "Existing AWS EC2 key pair name for SSH access when create_key_pair is false"
  type        = string
  default     = null
}

variable "allowed_ssh_cidr" {
  description = "CIDR allowed to SSH to EC2"
  type        = string
  default     = "0.0.0.0/0"
}

variable "allowed_ingress_cidr" {
  description = "CIDR allowed to access Jenkins and the app service"
  type        = string
  default     = "0.0.0.0/0"
}

variable "root_volume_size" {
  description = "Root disk size in GiB. 20-30 GiB is usually enough for Jenkins, Docker images, and k3s in this static-site setup"
  type        = number
  default     = 30
}