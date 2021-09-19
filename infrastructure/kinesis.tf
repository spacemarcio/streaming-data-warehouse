resource "aws_kinesis_firehose_delivery_stream" "redshift_stream" {
  name        = "stockprices-stream"
  destination = "redshift"

  s3_configuration {
    role_arn   = aws_iam_role.firehose_role.arn
    bucket_arn = aws_s3_bucket.stream.arn
    prefix = "transactions/"
    buffer_interval = 60
    buffer_size = 5
  }

  redshift_configuration {
    role_arn           = aws_iam_role.firehose_role.arn
    cluster_jdbcurl    = "jdbc:redshift://${aws_redshift_cluster.datawarehouse.endpoint}/${aws_redshift_cluster.datawarehouse.database_name}"
    username           = var.username
    password           = var.password
    data_table_name    = "transactions"
    copy_options       = "json 'auto'"
    cloudwatch_logging_options {
      enabled = true
      log_group_name = aws_cloudwatch_log_group.stockprices_log_group.name
      log_stream_name = aws_cloudwatch_log_stream.stockprices_log_stream.name
    }
  }
}

resource "aws_cloudwatch_log_group" "stockprices_log_group" {
  name = "stockprices"
}

resource "aws_cloudwatch_log_stream" "stockprices_log_stream" {
  name           = "stockprices"
  log_group_name = aws_cloudwatch_log_group.stockprices_log_group.name
}