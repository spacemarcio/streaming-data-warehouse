resource "aws_glue_catalog_database" "database" {
  name = "stockprices"
}

resource "aws_glue_crawler" "crawler" {
  database_name = aws_glue_catalog_database.database.name
  name          = "stockprices_crawler"
  role          = aws_iam_role.glue_role.arn

  s3_target {
    path = "s3://${aws_s3_bucket.stream.bucket}/transactions/"
    exclusions = ["manifests/**"]
  }
}

resource "aws_glue_trigger" "crawler_trigger" {
  name = "stockprices_crawler_trigger"
  type = "SCHEDULED"
  schedule = "cron(0/5 * * * ? *)"

  actions {
    crawler_name = aws_glue_crawler.crawler.name
  }
}