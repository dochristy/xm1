terraform {
  # The configuration for this backend will be filled in by Terragrunt
  backend "s3" {}
}

output "public_ip" {
  value = "${aws_instance.example.public_ip}"
}

provider "aws" {
  access_key = "AKIAI6G3UYUNUMX7RZIQ"
  secret_key = "P67oO/zpV5jQ13DxgIYKluid6ZzLag1GGj8T+1iF"
  region = "us-east-1"
}

resource "aws_instance" "example" {
  ami = "ami-2d39803a"
  instance_type = "t2.micro"
  vpc_security_group_ids = ["${aws_security_group.instance.id}"]
  user_data = <<-EOF
            #!/bin/bash
            echo "Hello, World" > index.html
            nohup busybox httpd -f -p "${var.server_port}" &
            EOF

  tags {
    Name = "terraform-example"
  }
}

resource "aws_security_group" "instance" {
  name = "terraform-example-instance"
  ingress {
    from_port = "${var.server_port}"
    to_port = "${var.server_port}"
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

variable "server_port" {
  description = "The port the server will use for HTTP requests"
}

resource "aws_s3_bucket" "my-terraform-state" {
bucket = "dochristy-e"
region = "us-east-1"
versioning {
enabled = true
}
lifecycle {
prevent_destroy = true
}
}

data "terraform_remote_state" "network" {
  backend = "s3"
  config {
    bucket = "dochristy-e"
    key    = "terraform.tfstate"
    region = "us-east-1"
  }
}
