# ====================================
# SHARED STORAGE MODULE
# ====================================
# S3 buckets for application storage and logging

# Random suffix for unique bucket names
resource "random_string" "bucket_suffix" {
  length  = 8
  special = false
  upper   = false
}

# Application storage bucket
resource "aws_s3_bucket" "app_storage" {
  bucket = "${var.bucket_prefix}-app-storage-${var.environment}-${random_string.bucket_suffix.result}"

  tags = merge(var.common_tags, {
    Name    = "${var.environment}-app-storage"
    Purpose = "Application Storage"
  })
}

# Bucket versioning
resource "aws_s3_bucket_versioning" "app_storage" {
  bucket = aws_s3_bucket.app_storage.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Bucket encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "app_storage" {
  bucket = aws_s3_bucket.app_storage.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Block public access
resource "aws_s3_bucket_public_access_block" "app_storage" {
  bucket = aws_s3_bucket.app_storage.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Lifecycle configuration (FREE TIER OPTIMIZED)
resource "aws_s3_bucket_lifecycle_configuration" "app_storage" {
  bucket = aws_s3_bucket.app_storage.id

  # OPTIMIZATION 5: Aggressive cleanup for free tier (stay under 5GB)
  rule {
    id     = "ml_training_data_lifecycle"
    status = "Enabled"

    # Only keep processed ML datasets, not raw logs
    filter {
      prefix = "ml-datasets/"
    }

    transition {
      days          = 7 # Move to cheaper storage quickly
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = 14 # Move to cheapest storage
      storage_class = "GLACIER"
    }

    expiration {
      days = 30 # Delete after 30 days (vs 90)
    }
  }

  # OPTIMIZATION 6: Quick cleanup of raw logs/temp data
  rule {
    id     = "temp_data_cleanup"
    status = "Enabled"

    filter {
      prefix = "temp/"
    }

    expiration {
      days = 3 # Delete temp data after 3 days
    }
  }

  # OPTIMIZATION 7: Clean up failed/incomplete uploads
  rule {
    id     = "incomplete_uploads"
    status = "Enabled"

    filter {
      prefix = "" # Apply to all objects
    }

    abort_incomplete_multipart_upload {
      days_after_initiation = 1
    }
  }
}

# Logging bucket (optional)
resource "aws_s3_bucket" "logs" {
  count  = var.enable_logging ? 1 : 0
  bucket = "${var.bucket_prefix}-logs-${var.environment}-${random_string.bucket_suffix.result}"

  tags = merge(var.common_tags, {
    Name    = "${var.environment}-logs"
    Purpose = "Log Storage"
  })
}

# Logging bucket encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "logs" {
  count  = var.enable_logging ? 1 : 0
  bucket = aws_s3_bucket.logs[0].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Block public access for logs
resource "aws_s3_bucket_public_access_block" "logs" {
  count  = var.enable_logging ? 1 : 0
  bucket = aws_s3_bucket.logs[0].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
} 