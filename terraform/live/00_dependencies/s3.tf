resource "aws_s3_bucket" "s3_codebuild" {
  bucket = "${var.project}-codebuild"
}

resource "aws_s3_bucket_public_access_block" "codebuild" {
  bucket = aws_s3_bucket.s3_codebuild.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

data "aws_iam_policy_document" "s3" {
  statement {
    sid    = "s3"
    effect = "Allow"
    principals {
      identifiers = ["arn:aws:iam::${var.accountid_prod}:root"]
      type        = "AWS"
    }
    actions = [
      "s3:Get*",
      "s3:Put*"
    ]
    resources = [
      "${aws_s3_bucket.s3_codebuild.arn}/*"
    ]
  }

  statement {
    sid    = "s3list"
    effect = "Allow"
    principals {
      identifiers = ["arn:aws:iam::${var.accountid_prod}:root"]
      type        = "AWS"
    }
    actions = [
      "s3:ListBucket"
    ]
    resources = [
      aws_s3_bucket.s3_codebuild.arn
    ]
  }
}

resource "aws_s3_bucket_policy" "s3" {
  bucket = aws_s3_bucket.s3_codebuild.id
  policy = data.aws_iam_policy_document.s3.json
}

resource "aws_s3_bucket_server_side_encryption_configuration" "example" {
  bucket = aws_s3_bucket.s3_codebuild.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = module.kms.key_arn
      sse_algorithm     = "aws:kms"
    }
    bucket_key_enabled = true
  }
}