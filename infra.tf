terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region  = "eu-central-1"
#   profile = "your profile"
}

resource "aws_security_group" "sg_prometheus_2" {
  name        = "ansible_instance_sg_prometheus_2"
  description = "Allow SSH, HTTP inbound traffic"

  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Grafana "
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "prometheus "
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "node_exporter "
    from_port   = 9100
    to_port     = 9100
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Alarmmanager  "
    from_port   = 9093
    to_port     = 9093
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_key_pair" "kp_prometheus" {
  key_name   = "ec2 key prometheus"
  public_key = file("~/.ssh/id_rsa.pub")
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance
resource "aws_instance" "prometheus_server" {
  ami             = "ami-065ab11fbd3d0323d"
  instance_type   = "t2.micro"
  security_groups = [aws_security_group.sg_prometheus_2.name]
  key_name        = aws_key_pair.kp_prometheus.key_name

  tags={
    name="prometheus_server"
  }
}
resource "aws_instance" "node_exporter" {
  ami             = "ami-065ab11fbd3d0323d"
  instance_type   = "t2.micro"
  security_groups = [aws_security_group.sg_prometheus_2.name]
  key_name        = aws_key_pair.kp_prometheus.key_name

  tags={
    name="node_exporter"
  }
}

output "prometheus_ip" {
  value = aws_instance.prometheus_server.public_ip 
  
}

output "node_exporter_ip" {
  
  value = aws_instance.node_exporter.public_ip
}