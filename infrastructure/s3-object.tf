resource "aws_s3_bucket_object" "job_spark" {
  bucket = aws_s3_bucket.code.id
  key    = "calculate_bollinger_bands.py"
  acl    = "private"
  source = "../airflow/codes/calculate_bollinger_bands.py"
  etag   = filemd5("../airflow/codes/calculate_bollinger_bands.py")
}