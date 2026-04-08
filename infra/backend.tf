terraform {
  backend "s3" {
    bucket = "day5-bootstrap-bucket"
    key    = "terraform.tfstate"
    region = "eu-north-1"
    dynamodb_table = "day5-bootstrap-table-lock"
  }
}
