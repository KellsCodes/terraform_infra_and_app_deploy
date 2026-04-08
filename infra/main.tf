provider "aws" {
  region = "eu-north-1"
}

module "ec2_instance" {
  source = "./modules/ec2_instance"

  ami_value           = "ami-080254318c2d8932f"
  instance_type_value = "t3.small"
  subnet_id_value     = "subnet-0b07453b626f40f14"
}
