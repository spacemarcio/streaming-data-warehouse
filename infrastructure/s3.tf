resource "aws_s3_bucket" "stream" {
  bucket = "stockprices-data"
  acl    = "private"
}

resource "aws_s3_bucket" "code" {
  bucket = "stockprices-code"
  acl    = "private"
}

resource "aws_s3_bucket" "emr" {
  bucket = "stockprices-emr-logs"
  acl    = "private"
}