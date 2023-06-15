data "azurerm_key_vault" "redcap" {
  name                = var.keyvault_name
  resource_group_name = var.resource_group_name
}

data "azurerm_application_insights" "redcap" {
  name                = var.app_insights_name
  resource_group_name = var.resource_group_name
}
