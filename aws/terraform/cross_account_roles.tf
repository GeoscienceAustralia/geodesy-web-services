module "cross_account_access_role" {
  source = "git@github.com:infrablocks/terraform-aws-cross-account-role.git?ref=0.3.0"

  role_name  = aws_iam_policy.access.name
  policy_arn = aws_iam_policy.access.arn

  assumable_by_account_ids = var.assumable_by_account_ids
}

resource "aws_iam_policy" "access" {
  name = "${aws_s3_bucket.gnss_metadata_document_storage.bucket}-access"
  path = "/"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:Get*",
        "s3:List*",
        "s3:DeleteObject",
        "s3:PutObject",
        "s3:PutObjectAcl"
      ],
      "Effect": "Allow",
      "Resource": [
        "${aws_s3_bucket.gnss_metadata_document_storage.arn}",
        "${aws_s3_bucket.gnss_metadata_document_storage.arn}/*"
      ]
    }
  ]
}
EOF
}

output "access_role_arn" {
  value = module.cross_account_access_role.role_arn
}
