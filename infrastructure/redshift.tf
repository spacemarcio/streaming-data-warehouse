resource "aws_redshift_cluster" "datawarehouse" {
  cluster_identifier          = "stockprices-dw"
  database_name               = "stockprices"
  master_username             = var.username
  master_password             = var.password
  node_type                   = "dc2.large"
  cluster_type                = "single-node"
  automated_snapshot_retention_period = 0
}