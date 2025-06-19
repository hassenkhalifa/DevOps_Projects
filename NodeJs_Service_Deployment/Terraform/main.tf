terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}


resource "aws_key_pair" "deploy" {
  key_name   = "deploy-key"
  public_key = var.ssh_public_key


}

resource "aws_security_group" "ssh_access" {
  name        = "ssh_access"
  description = "Allow SSH inbound traffic"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_ssh"
  }

}

resource "aws_security_group" "Node_App" {
  name        = "Node_App"
  description = "Node application inbound traffic"

  ingress {
    description = "NodeJsApp"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Node_App"
  }

}

resource "aws_security_group" "MULTI_CONTAINER_APP" {
  name        = "Multi_Container_App"
  description = "Security group for multi-container app inbound traffic"

  ingress {
    description = "Vote service"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Result service"
    from_port   = 8081
    to_port     = 8081
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "MULTI_CONTAINER_APP"
  }
}


resource "aws_instance" "ubuntu_server" {
  ami                         = "ami-020cba7c55df1f615"
  instance_type               = "t2.micro"
  key_name                    = aws_key_pair.deploy.key_name
  vpc_security_group_ids      = [aws_security_group.ssh_access.id, aws_security_group.Node_App.id]
  associate_public_ip_address = true

  tags = {
    Name = "Ubuntu-Server"
  }

}

# Elastic IP (EIP)
resource "aws_eip" "static_ip" {
  instance   = aws_instance.ubuntu_server.id
  domain     = "vpc"
  depends_on = [aws_instance.ubuntu_server]
}

# Création de la zone Route 53 publique
resource "aws_route53_zone" "hassendevops_zone" {
  name = "hassendevops.com"
  comment = "Zone publique pour hassendevops.com"
}

# Enregistrement DNS Route 53
resource "aws_route53_record" "dns_record" {
  zone_id = aws_route53_zone.hassendevops_zone.zone_id
  name    = "ec2.hassendevops.com"
  type    = "A"
  ttl     = 300
  records = [aws_eip.static_ip.public_ip]
  depends_on = [aws_eip.static_ip]
}
