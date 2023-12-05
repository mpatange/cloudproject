provider "aws" {
  region = "us-west-2"
}

data "aws_ami" "latest_amazon_linux" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["amazon"]
}

resource "aws_instance" "django-app" {
  ami           = data.aws_ami.latest_amazon_linux.id
  instance_type = "t2.micro"

  tags = {
    Name = "MIS547_MovieRecommender"
  }
  
  user_data = <<-EOF
                #!/bin/bash
                sudo yum update -y
                sudo yum install -y docker
                sudo service docker start
                sudo docker pull mpatange/movie-app:latest
                sudo docker run -d -p 80:8000 mpatange/movie-app:latest
                EOF

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("${path.module}/django-key.pem")
    host        = self.public_ip
  }
}

output "public_ip" {
  value = aws_instance.django-app.public_ip
}
