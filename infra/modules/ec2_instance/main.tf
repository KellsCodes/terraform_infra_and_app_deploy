terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

# Define the key pair
resource "aws_key_pair" "iac_key" {
  key_name   = "terraform_key"
  public_key = file("~/.ssh/id_rsa.pub")
}

# create vpc
resource "aws_vpc" "iac_vpc" {
  cidr_block           = var.cidr_value
  enable_dns_support   = true
  enable_dns_hostnames = true
}

# create subnet
resource "aws_subnet" "sub1" {
  vpc_id                  = aws_vpc.iac_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "eu-north-1a"
  map_public_ip_on_launch = true
}

# Create internet gateway
resource "aws_internet_gateway" "iac_igw" {
  vpc_id = aws_vpc.iac_vpc.id
}

# create route table
resource "aws_route_table" "iac_route_table" {
  vpc_id = aws_vpc.iac_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.iac_igw.id
  }
}

# associate route table to the subnet sub1
resource "aws_route_table_association" "rta1" {
  subnet_id      = aws_subnet.sub1.id
  route_table_id = aws_route_table.iac_route_table.id
}

# create security group
resource "aws_security_group" "iacSg" {
  name   = "web"
  vpc_id = aws_vpc.iac_vpc.id

  ingress {
    description = "HTTP from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
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

  tags = {
    Name = "Day5 WebServer SG"
  }
}

# Create the EC2 instance
resource "aws_instance" "webserver" {
  ami                    = var.ami_value
  instance_type          = var.instance_type_value
  key_name               = aws_key_pair.iac_key.key_name
  vpc_security_group_ids = [aws_security_group.iacSg.id]
  subnet_id              = aws_subnet.sub1.id

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("~/.ssh/id_rsa")
    host        = self.public_ip
  }

  # File provisioner to upload files to the EC2 instance from local file
  provisioner "file" {
    source      = "../app/src"
    destination = "/home/ubuntu/src"
  }

  # Remote exec provisioner to run commands on the EC2 instance
  provisioner "remote-exec" {
    inline = [
      "echo 'Starting deployment...'",
      "sudo apt update -y", # Update package lists (for ubuntu)
      "sudo apt-get install -y python3-pip python3-venv",
      "cd /home/ubuntu/src",
      "python3 -m venv venv",
      "./venv/bin/pip install -r requirements.txt",
      "sudo nohup ./venv/bin/python app.py > flask.log 2>&1 &",
      "sleep 3", # Give it a moment to start
      "cat flask.log",
      "echo 'Deployment finished!'",
      "echo \"Access your site at: http://$(curl -s ifconfig.me)\"",
      "ps aux | grep python"
    ]
  }

  tags = {
    Name = "Day5 WebServer"
  }
}
