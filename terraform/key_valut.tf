
resource "azurerm_key_vault" "redcap" {
  name                          = "kv-${local.suffix_short}"
  location                      = azurerm_resource_group.redcap.location
  resource_group_name           = azurerm_resource_group.redcap.name
  tenant_id                     = data.azurerm_client_config.current.tenant_id
  enabled_for_disk_encryption   = false
  public_network_access_enabled = true
  soft_delete_retention_days    = 7
  purge_protection_enabled      = false
  enable_rbac_authorization     = true
  sku_name                      = "standard"
  tags                          = local.tags

  network_acls {
    bypass         = "AzureServices"
    default_action = "Deny"
    ip_rules       = var.debug ? [local.deployers_ip] : []
  }
}

resource "azurerm_role_assignment" "deployer_can_administrate_kv" {
  scope                = azurerm_key_vault.redcap.id
  role_definition_name = "Key Vault Administrator"
  principal_id         = data.azurerm_client_config.current.object_id
}

resource "azurerm_private_endpoint" "keyvault" {
  name                = "pe-${azurerm_key_vault.redcap.name}"
  location            = azurerm_resource_group.redcap.location
  resource_group_name = azurerm_resource_group.redcap.name
  subnet_id           = azurerm_subnet.shared.id
  tags                = local.tags

  private_dns_zone_group {
    name                 = "private-dns-zone-group${azurerm_key_vault.redcap.name}"
    private_dns_zone_ids = [azurerm_private_dns_zone.all["keyvault"].id]
  }

  private_service_connection {
    name                           = "private-service-connection-${azurerm_key_vault.redcap.name}"
    is_manual_connection           = false
    private_connection_resource_id = azurerm_key_vault.redcap.id
    subresource_names              = ["Vault"]
  }
}
