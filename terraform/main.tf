#########################################
# Terraform AWS Config
#########################################

provider "aws" {
  region = "us-east-1"  
}

# Generate SSH key locally
resource "tls_private_key" "mykey" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Create AWS Key Pair
resource "aws_key_pair" "terraform_key" {
  key_name   = "terraform-key"
  public_key = tls_private_key.mykey.public_key_openssh
}

# Save PEM file locally
resource "local_file" "private_key_pem" {
  content  = tls_private_key.mykey.private_key_pem
  filename = "${path.module}/terraform-key.pem"
}

# Security Group (allow HTTP, SSH)
resource "aws_security_group" "terraform_sg" {
  name        = "terraform-sg"
  description = "Allow SSH, HTTP, HTTPS"
  vpc_id      = "vpc-0115610baab458781"   

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "SSH"
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTP"
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTPS"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Get latest Ubuntu 20.04 AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
}

# Controller node
resource "aws_instance" "controller" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.terraform_key.key_name
  vpc_security_group_ids = [aws_security_group.terraform_sg.id]
  subnet_id              = "subnet-0ad5c79dad63012ff"  

  tags = { Name = "Controller" }
}

# Manager node
resource "aws_instance" "manager" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.terraform_key.key_name
  vpc_security_group_ids = [aws_security_group.terraform_sg.id]
  subnet_id              = "subnet-0ad5c79dad63012ff"

  tags = { Name = "Manager" }
}

# Worker A
resource "aws_instance" "worker_a" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.terraform_key.key_name
  vpc_security_group_ids = [aws_security_group.terraform_sg.id]
  subnet_id              = "subnet-0ad5c79dad63012ff"

  tags = { Name = "WorkerA" }
}

# Worker B
resource "aws_instance" "worker_b" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.terraform_key.key_name
  vpc_security_group_ids = [aws_security_group.terraform_sg.id]
  subnet_id              = "subnet-0ad5c79dad63012ff"

  tags = { Name = "WorkerB" }
}

# Elastic IPs
resource "aws_eip" "controller_ip" { instance = aws_instance.controller.id }
resource "aws_eip" "manager_ip"    { instance = aws_instance.manager.id }
resource "aws_eip" "worker_a_ip"   { instance = aws_instance.worker_a.id }
resource "aws_eip" "worker_b_ip"   { instance = aws_instance.worker_b.id }

# Outputs
output "controller_public_ip" { value = aws_eip.controller_ip.public_ip }
output "manager_public_ip"    { value = aws_eip.manager_ip.public_ip }
output "worker_a_public_ip"   { value = aws_eip.worker_a_ip.public_ip }
output "worker_b_public_ip"   { value = aws_eip.worker_b_ip.public_ip }
