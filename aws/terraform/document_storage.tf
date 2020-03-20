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

output "gnss_metadata_document_storage_bucket" {
  value = aws_s3_bucket.gnss_metadata_document_storage.bucket
}
