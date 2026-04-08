terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

resource "aws_instance" "webserver" {
  ami           = var.ami_value
  instance_type = var.instance_type_value
  subnet_id     = var.subnet_id_value

  tags = {
    Name = "Day5 WebServer"
  }
}
