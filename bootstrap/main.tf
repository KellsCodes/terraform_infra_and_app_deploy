provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "bootstrap_bucket" {
  bucket = "day5-bootstrap-bucket"
}

resource "aws_dynamodb_table" "bootstrap_table" {
  name         = "day5-bootstrap-table-lock"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

}
