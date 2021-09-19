# Imagem Ubuntu
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "airflow" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t3.large"
  key_name                    = "bitcoin"
  associate_public_ip_address = true
  security_groups             = [aws_security_group.airflow_sg.id]
  subnet_id                   = "subnet-64bcc128" # my default subnet
  
  root_block_device {
    volume_size = 64
  }
}
resource "aws_security_group" "airflow_sg" {
  name        = "airflow_sg"
  description = "Allow traffic for Airflow"
  vpc_id      = "vpc-0266d269" # my default VPC

  ingress {
    description      = "TLS from VPC"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}