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
  # Install Docker
  curl -fsSL https://get.docker.com -o get-docker.sh
  sudo sh get-docker.sh
  # Add user to Docker group
  sudo usermod -aG docker ubuntu
  # Enable and start Docker
  sudo systemctl enable docker
  sudo systemctl start docker
  # Run Docker container with port mapping
  sudo docker pull andriypolyuh/aws:latest
  sudo docker run -d -p 8088:8088 andriypolyuh/aws:latest
  EOF

  tags = {
    Name = "web_instance"
  }
}


output "instance_public_ip" {
  value     = aws_instance.web_instance.public_ip
  sensitive = true
}
