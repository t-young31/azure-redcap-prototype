resource "azurerm_container_registry" "redcap" {
  name                          = var.acr_name
  resource_group_name           = azurerm_resource_group.redcap.name
  location                      = azurerm_resource_group.redcap.location
  sku                           = "Standard"
  admin_enabled                 = true
  public_network_access_enabled = true
}
