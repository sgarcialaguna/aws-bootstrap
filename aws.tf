provider "aws" {
  region = "eu-central-1"
}

resource "aws_instance" "webserver" {
  ami             = "ami-076431be05aaf8080"
  instance_type   = "t2.micro"
  security_groups = ["${aws_security_group.webserver_sg.name}"]
  key_name        = "default"
  user_data       = file("boot.sh")
}

resource "aws_security_group" "webserver_sg" {
  name = "Allow access to webserver"
  ingress {
    description = "Allow access to webserver"
    from_port   = 8081
    to_port     = 8081
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Allow SSH to webserver"
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
}

resource "aws_s3_bucket" "my-code-deploy-bucket" {
  acl           = "private"
  force_destroy = false
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}
