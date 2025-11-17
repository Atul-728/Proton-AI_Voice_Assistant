provider "aws" {
  region     = "us-east-1"
  access_key = var.access_key
  secret_key = var.secret_key
}

data "aws_ami" "windows" {
  most_recent = true
  filter {
    name   = "name"
    values = ["Windows_Server-2022-English-Full-Base-*"]
  }
  owners = ["amazon"]
}

resource "aws_security_group" "proton_sg" {
  name        = "proton-sg"
  description = "Allow RDP and WinRM"
  ingress {
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = [var.allowed_cidr]
  }
  ingress {
    from_port   = 5985
    to_port     = 5985
    protocol    = "tcp"
    cidr_blocks = [var.allowed_cidr]
  }
  ingress {
    from_port   = 5986
    to_port     = 5986
    protocol    = "tcp"
    cidr_blocks = [var.allowed_cidr]
  }
    egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

resource "aws_instance" "proton_win" {
  ami           = data.aws_ami.windows.id
  instance_type = var.instance_type
  key_name      = var.key_name
  security_groups = [aws_security_group.proton_sg.name]
  tags = { Name = "proton-windows" }
}