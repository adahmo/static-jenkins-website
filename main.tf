data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

locals {
  resolved_generated_key_name = try(trimspace(var.generated_key_name), "") != "" ? var.generated_key_name : "${var.project_name}-key"
  generated_private_key_file  = try(trimspace(var.private_key_output_file), "") != "" ? abspath(var.private_key_output_file) : "${path.module}/${local.resolved_generated_key_name}.pem"
  effective_key_name          = var.create_key_pair ? aws_key_pair.generated[0].key_name : try(trimspace(var.key_name), "")
}

resource "tls_private_key" "generated" {
  count     = var.create_key_pair ? 1 : 0
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated" {
  count      = var.create_key_pair ? 1 : 0
  key_name   = local.resolved_generated_key_name
  public_key = tls_private_key.generated[0].public_key_openssh

  tags = {
    Name = local.resolved_generated_key_name
  }
}

resource "local_sensitive_file" "generated_private_key" {
  count    = var.create_key_pair ? 1 : 0
  filename = local.generated_private_key_file
  content  = tls_private_key.generated[0].private_key_pem
}

resource "aws_security_group" "devops_sg" {
  name        = "${var.project_name}-sg"
  description = "Allow SSH, Jenkins and app access"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ssh_cidr]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ingress_cidr]
  }

  ingress {
    from_port   = 30080
    to_port     = 30080
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ingress_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-sg"
  }
}

resource "aws_instance" "devops_server" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  subnet_id                   = data.aws_subnets.default.ids[0]
  vpc_security_group_ids      = [aws_security_group.devops_sg.id]
  key_name                    = local.effective_key_name
  associate_public_ip_address = true

  user_data = templatefile("${path.module}/templates/user_data.sh.tftpl", {})

  lifecycle {
    precondition {
      condition     = var.create_key_pair || try(trimspace(var.key_name), "") != ""
      error_message = "Set key_name when create_key_pair is false, or leave create_key_pair enabled to have Terraform generate one automatically."
    }
  }

  root_block_device {
    volume_type           = "gp3"
    volume_size           = var.root_volume_size
    delete_on_termination = true
  }

  tags = {
    Name = "${var.project_name}-ec2"
  }
}