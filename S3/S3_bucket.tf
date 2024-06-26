resource "aws_s3_bucket" "bucket" {
  count = var.enabled ? 1 : 0

  bucket = var.s3_bucket_name
  }

resource "aws_s3_bucket_ownership_controls" "bucket" {
  count = var.enabled ? 1 : 0
  bucket = aws_s3_bucket.bucket[count.index].id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "bucket" {
  count = var.enabled ? 1 : 0
  depends_on = [aws_s3_bucket_ownership_controls.bucket]

  bucket = aws_s3_bucket.bucket[count.index].id
  acl    = "private"
}

resource "aws_s3_bucket_lifecycle_configuration" "bucket-config" {
  count = var.enabled ? 1 : 0
  bucket = aws_s3_bucket.bucket[count.index].id

  rule {
    id = "log"

    expiration {
      days = 90
    }

    filter {
      and {
        prefix = "log/"

        tags = {
          rule      = "log"
          autoclean = "true"
        }
      }
    }

    status = "Enabled"

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = 60
      storage_class = "GLACIER"
    }
  }

  rule {
    id = "tmp"

    filter {
      prefix = "tmp/"
    }

    expiration {
      date = "2023-01-13T00:00:00Z"
    }

    status = "Enabled"
  }
}