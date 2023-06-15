resource "azurerm_storage_account" "redcap" {
  name                     = "strg${local.suffix_short}"
  resource_group_name      = azurerm_resource_group.redcap.name
  location                 = azurerm_resource_group.redcap.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  tags                     = local.tags

  network_rules {
    default_action = "Deny"

    ip_rules = [local.deployers_ip]

    bypass = [
      "AzureServices",
      "Logging",
      "Metrics"
    ]
  }
}

resource "azurerm_private_endpoint" "blob" {
  name                = "pe-${azurerm_storage_account.redcap.name}"
  resource_group_name = azurerm_resource_group.redcap.name
  location            = azurerm_resource_group.redcap.location
  tags                = local.tags
  subnet_id           = azurerm_subnet.shared.id

  private_dns_zone_group {
    name                 = "dns-zone-group-strg"
    private_dns_zone_ids = [azurerm_private_dns_zone.all["blob"].id]
  }

  private_service_connection {
    name                           = "pe-service-connection-strg"
    private_connection_resource_id = azurerm_storage_account.redcap.id
    is_manual_connection           = false
    subresource_names              = ["blob"]
  }
}
