resource "azurerm_resource_group" "redcap" {
  name     = "rg-${var.suffix}"
  location = local.location
  tags     = local.tags
}

module "redcap" {
  source = "./redcap"

  suffix              = var.suffix
  suffix_short        = local.suffix_short
  tags                = local.tags
  resource_group_name = azurerm_resource_group.redcap.name
  location            = azurerm_resource_group.redcap.location
  keyvault_id         = azurerm_key_vault.redcap.id
  storage_account_key = azurerm_storage_account.redcap.primary_access_key
  subnets             = {
    shared = azurerm_subnet.shared
    webapp = azurerm_subnet.webapp
  }

  depends_on = [
    azurerm_role_assignment.deployer_can_administrate_kv
  ]
}
