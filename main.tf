terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.5"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

############################
# LLAVES SSH
############################

# Genera una llave privada de forma dinámica
resource "tls_private_key" "rsa_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Registra la llave pública en AWS con tu nomenclatura
resource "aws_key_pair" "deployer_key" {
  key_name   = "AUY1105-duocapp-key"
  public_key = tls_private_key.rsa_key.public_key_openssh
}

# Guarda la llave privada en tu máquina local para el provisioner y uso manual
resource "local_file" "private_key" {
  content         = tls_private_key.rsa_key.private_key_pem
  filename        = "AUY1105-duocapp-key.pem"
  file_permission = "0400"
}

############################
# NETWORKING
############################

# VPC: Bloque CIDR 10.1.0.0/16
resource "aws_vpc" "main" {
  cidr_block           = "10.1.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "AUY1105-duocapp-vpc"
  }
}

# Subredes /24
resource "aws_subnet" "public_a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.1.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "AUY1105-duocapp-subnet-a"
  }
}

resource "aws_subnet" "public_b" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.1.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "AUY1105-duocapp-subnet-b"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "AUY1105-duocapp-igw"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "AUY1105-duocapp-rt"
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public.id
}

############################
# SECURITY GROUPS
############################

# Solo permite SSH (Puerto 22) según instrucción 3
resource "aws_security_group" "web" {
  name   = "AUY1105-duocapp-sg"
  vpc_id = aws_vpc.main.id

  ingress {
    description = "Allow SSH only"
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
    Name = "AUY1105-duocapp-sg"
  }
}

############################
# CÓMPUTO
############################

# EC2: Ubuntu 24.04 LTS tipo t2.micro
resource "aws_instance" "app" {
  ami                    = "ami-04b70fa74e45c3917" # Ubuntu 24.04 LTS Noble en us-east-1
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public_a.id
  vpc_security_group_ids = [aws_security_group.web.id]
  key_name               = aws_key_pair.deployer_key.key_name

  tags = {
    Name = "AUY1105-duocapp-ec2"
  }

  # Provisionamiento (Uso de llave dinámica)
  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update -y",
      "sudo apt-get install -y apache2",
      "sudo systemctl start apache2"
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = tls_private_key.rsa_key.private_key_pem
      host        = self.public_ip
    }
  }
}

############################
# OUTPUTS
############################

output "instance_public_ip" {
  value = aws_instance.app.public_ip
}
