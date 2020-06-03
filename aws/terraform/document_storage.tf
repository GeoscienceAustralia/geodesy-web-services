resource "aws_s3_bucket" "gnss_metadata_document_storage" {
  bucket = "gnss-metadata-document-storage-${var.environment}"
  acl    = "public-read"

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET"]
    allowed_origins = ["*"]
    max_age_seconds = 3000
  }
}

resource "aws_s3_bucket_policy" "document_storage" {
  bucket = aws_s3_bucket.gnss_metadata_document_storage.id

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:DeleteObject",
        "s3:PutObject",
        "s3:PutObjectAcl"
      ],
      "Effect": "Allow",
      "Principal": {
        "AWS": "094928090547"
      },
      "Resource": [
        "${aws_s3_bucket.gnss_metadata_document_storage.arn}",
        "${aws_s3_bucket.gnss_metadata_document_storage.arn}/*"
      ]
    }
  ]
}
POLICY
}

output "gnss_metadata_document_storage_bucket" {
  value = aws_s3_bucket.gnss_metadata_document_storage.bucket
}
