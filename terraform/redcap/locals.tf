locals {
  mysql_admin_username = "adminuser"
  mysql_admin_password = random_password.mysql.result
  mysql_database_name  = "redcap_db"

  secrets = {
    mysql-password      = local.mysql_admin_password
    storage-account-key = azurerm_storage_account.redcap.primary_access_key
    connection-string   = "Database=${local.mysql_database_name};Data Source=${azurerm_mysql_flexible_server.redcap.fqdn};User Id=${local.mysql_admin_username}@${azurerm_mysql_flexible_server.redcap.name};Password=${local.mysql_admin_password}"
  }

  tags = var.tags
}
