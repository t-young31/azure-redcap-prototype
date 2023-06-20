resource "random_password" "mysql" {
  length           = 32
  special          = true
  min_lower        = 1
  min_numeric      = 1
  min_special      = 1
  min_upper        = 1
  override_special = "_%@"
}

resource "azurerm_mysql_flexible_server" "redcap" {
  name                   = "mysql${var.suffix_short}"
  resource_group_name    = var.resource_group_name
  location               = var.location
  tags                   = local.tags
  administrator_login    = local.mysql_admin_username
  administrator_password = local.mysql_admin_password
  sku_name               = "B_Standard_B1s" # TODO: alter for prod e.g. GP_Standard_D2ds_v4

  delegated_subnet_id = var.subnets["mysql"].id
  private_dns_zone_id = var.dns_zones["mysql"].id

  storage {
    size_gb           = 20 # TODO: alter for prod e.g. 100?
    auto_grow_enabled = true
    iops              = 360
  }

  version                      = "5.7"
  backup_retention_days        = 7
  geo_redundant_backup_enabled = false # TODO: alter for prod e.g. true
  zone                         = "1"
}

resource "azurerm_mysql_flexible_database" "redcap" {
  name                = local.mysql_database_name
  resource_group_name = var.resource_group_name
  server_name         = azurerm_mysql_flexible_server.redcap.name
  charset             = "utf8"
  collation           = "utf8_unicode_ci"
}
