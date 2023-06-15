locals {
  mssql_admin_username = "adminuser"
  mssql_admin_password = random_password.mssql.result
  mssql_database_name  = "redcap_db"

  secrets = {
    mssql-password      = local.mssql_admin_password
    storage-account-key = var.storage_account_key
    connection-string = "Database=${local.mssql_database_name};Data Source=${azurerm_mysql_flexible_server.redcap.fqdn};User Id=${local.mssql_admin_username}@mysql-${azurerm_mysql_flexible_server.redcap.name};Password=${local.mssql_admin_password}"
    # redcap-zipfile = var.redcap_zip_file_url
    # redcap-username = 
    # redcap-password =

  }
  tags = var.tags
}
