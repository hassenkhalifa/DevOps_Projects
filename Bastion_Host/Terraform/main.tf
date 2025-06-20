terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

data "http" "my_ip" {
  url = "https://checkip.amazonaws.com/"
}

resource "aws_key_pair" "deploy" {
  key_name   = "deploy-key"
  public_key = var.ssh_public_key
}

resource "aws_security_group" "ssh_exclusive_access" {
  name        = "ssh_exclusive_access"
  description = "Allow SSH inbound traffic from my IP"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${chomp(data.http.my_ip.body)}/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_ssh_exclusive"
  }
}

resource "aws_security_group" "ssh_private_access" {
  name        = "ssh_private_access"
  description = "Allow SSH inbound traffic from Bastion Host"

  ingress {
    description     = "SSH from Bastion"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.ssh_exclusive_access.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_ssh_private"
  }
}

resource "aws_instance" "Bastion_Host" {
  ami                         = "ami-020cba7c55df1f615"
  instance_type               = "t2.micro"
  key_name                    = aws_key_pair.deploy.key_name
  vpc_security_group_ids      = [aws_security_group.ssh_exclusive_access.id]
  associate_public_ip_address = true

  tags = {
    Name = "Bastion_Host"
  }
}

resource "aws_instance" "Private_Server" {
  ami                         = "ami-020cba7c55df1f615"
  instance_type               = "t2.micro"
  key_name                    = aws_key_pair.deploy.key_name
  vpc_security_group_ids      = [aws_security_group.ssh_private_access.id]
  associate_public_ip_address = false

  tags = {
    Name = "Private_Server"
  }
}