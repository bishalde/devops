provider "aws" {
  region = "us-east-1"
}

resource "aws_security_group" "my_security_group" {
  name        = "mydevops_sg"
  description = "Security group for mydevopsinstance"

  // Define inbound rules
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  // Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "mydevopsinstance" {
  ami             = "ami-07d9b9ddc6cd8dd30"
  instance_type   = "t2.micro"
  security_groups = [aws_security_group.my_security_group.name]
  key_name        = "devops"
  tags = {
    "Name" : "mydevopsinstance"
  }


  provisioner "remote-exec" {
    inline = [
      "sudo apt update",
      "sudo apt install fontconfig openjdk-17-jre -y",
      "sudo wget -O /usr/share/keyrings/jenkins-keyring.asc https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key",                                                     
      "echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/ | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null", 
      "sudo apt-get update",
      "sudo apt-get install jenkins -y",
      "sudo systemctl enable jenkins",
      "sudo systemctl start jenkins",
      "sudo systemctl status jenkins"
    ]



    connection {
      type        = "ssh"
      user        = "ubuntu" // Change to the appropriate user for your AMI
      private_key = file("devops.pem")
      host        = self.public_ip
    }
  }
}
