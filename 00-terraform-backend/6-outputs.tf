output "dynamodb_lock_table_name" {
  description = "The name of the DynamoDB table used for Terraform state locking."
  value       = aws_dynamodb_table.example_table.name
}

output "s3_backend_bucket_name" {
  description = "The name of the S3 bucket used for Terraform state."
  value       = aws_s3_bucket.terraform_backend_bucket.id
}
