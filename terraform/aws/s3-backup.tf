resource "aws_s3_bucket" "backrest" {
  bucket = "backrest-bucket"

  tags = {
    Name  = "Backrest Bucket"
    Usage = "backup"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "deep_archive_lifecycle" {
  bucket = aws_s3_bucket.backrest.id

  rule {
    id     = "transition-to-deep-archive"
    status = "Enabled"

    filter {
      prefix = "" # Applies to all objects
    }

    transition {
      days          = 3
      storage_class = "DEEP_ARCHIVE"
    }
  }
}

resource "aws_iam_user" "backrest" {
  name = "backrest"
  tags = {
    Usage = "backup"
  }
}

resource "aws_iam_policy" "backrest_backup_policy" {
  name        = "BackrestAccessPolicy"
  description = "Allow access to deep-archive-bucket for backrest user"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.backrest.arn
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        Resource = [
          "${aws_s3_bucket.backrest.arn}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_user_policy_attachment" "backrest_backup_attach" {
  user       = aws_iam_user.backrest.name
  policy_arn = aws_iam_policy.backrest_backup_policy.arn
}