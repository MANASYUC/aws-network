resource "aws_s3_bucket" "log_storage" {
  bucket = var.log_bucket_name
  force_destroy = true
  tags = var.tags
}

resource "aws_s3_bucket_public_access_block" "log_storage" {
  bucket = aws_s3_bucket.log_storage.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "log_storage" {
  bucket = aws_s3_bucket.log_storage.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "random_id" "bucket_suffix" {
  byte_length = 8
}

