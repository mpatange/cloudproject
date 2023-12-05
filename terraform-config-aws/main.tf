provider "aws" {
  region = "us-west-2"  # Specify your AWS region
}

# Data source to get the latest Windows Server AMI
data "aws_ami" "latest_windows_server" {
  most_recent = true

  filter {
    name   = "name"
    values = ["Windows_Server-2019-English-Full-Base-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["amazon"]
}

# Create a new key pair for SSH access
resource "aws_key_pair" "webserver_key_pair" {
  key_name   = "webserver-key"
  public_key = file("C:/Users/mansi/Documents/webserver-key.pub")   # Update the path to your public key 
}

# Create a security group for the Windows Server instance
resource "aws_security_group" "windows_sg" {
  name        = "windows-server-sg"
  description = "Security group for Windows Server instance"

  # RDP access
  ingress {
    description = "RDP"
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = ["your.ip.address.range/32"]  # Replace with your IP range
  }

  # HTTP access
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTPS access
  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Standard outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Launch an EC2 instance with the Windows Server AMI
resource "aws_instance" "windows_server" {
  ami           = data.aws_ami.latest_windows_server.id
  instance_type = "t2.micro"
  key_name      = aws_key_pair.webserver_key_pair.key_name
  security_groups = [aws_security_group.windows_sg.name]

  tags = {
    Name = "WindowsServerInstance"
  }
}

# Output the public IP of the Windows Server instance
output "windows_server_public_ip" {
  value = aws_instance.windows_server.public_ip
}
