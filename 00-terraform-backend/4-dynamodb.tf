resource "aws_dynamodb_table" "example_table" {
  name           = "example-table-1"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "LockID"
  read_capacity  = 0
  write_capacity = 0

  attribute {
    name = "LockID"
    type = "S"
  }
  tags=local.common_tags
}