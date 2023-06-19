resource "azurerm_service_plan" "redcap" {
  name                = "asp-${var.suffix}"
  resource_group_name = azurerm_resource_group.redcap.name
  location            = azurerm_resource_group.redcap.location
  tags                = local.tags
  os_type             = "Linux"
  sku_name            = "P2v2" # TODO: prod, configureable
}

resource "azurerm_application_insights" "redcap" {
  name                = "appi-redcap-${var.suffix}"
  resource_group_name = azurerm_resource_group.redcap.name
  location            = azurerm_resource_group.redcap.location
  application_type    = "web"
  tags                = local.tags
}
