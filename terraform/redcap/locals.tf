locals {
  secrets = {
    mssql-password = random_password.mssql.result
  }
  tags = var.tags
}
