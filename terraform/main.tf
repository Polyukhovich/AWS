terraform {
  required_version = ">=0.13.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
backend "s3" {
    bucket = "lab67-my-tf-state"
    key = "terraform.tfstate"
    region = "us-east-1"
    dynamodb_table = "lab67-my-tf-lockid" 

  }
}

# Configure the AWS provider
provider "aws" {
  region     = "us-east-1"
}

resource "aws_security_group" "web_app" {
  name        = "web_app"
  description = "security group"
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

 ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags= {
    Name = "web_app"
  }
}

resource "aws_instance" "web_instance" {
  ami           = "ami-0166fe664262f664c"
  instance_type = "t2.micro"
  security_groups = ["web_app"]
 user_data = <<-EOF
  #!/bin/bash
  # Встановлення Docker
  curl -fsSL https://get.docker.com -o get-docker.sh
  sudo sh get-docker.sh
  sudo usermod -aG docker ec2-user  # Додавання користувача ec2-user в групу docker

  # Перезавантаження групи для користувача
  newgrp docker

  # Завантаження і запуск контейнера
  docker pull andriypolyuh/aws:latest
  docker run -id -p 8088:8088 andriypolyuh/aws:latest

  # Перевірка, чи запущено Docker
  docker ps
  EOF

  tags = {
    Name = "webapp_instance"
  }
}


output "instance_public_ip" {
  value     = aws_instance.web_instance.public_ip
  sensitive = true
}
