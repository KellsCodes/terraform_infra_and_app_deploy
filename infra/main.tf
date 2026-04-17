provider "aws" {
  region = "eu-north-1"
}

module "ec2_instance" {
  source = "./modules/ec2_instance"

  ami_value           = "ami-080254318c2d8932f"
  instance_type_value = "t3.small"
  cidr_value          = "10.0.0.0/16"
}

