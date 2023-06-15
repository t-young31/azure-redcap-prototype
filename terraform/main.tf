resource "azurerm_resource_group" "redcap" {
  name     = "rg-${var.suffix}"
  location = local.location
  tags     = local.tags
}

module "redcap" {
  source = "./redcap"

  suffix              = var.suffix
  tags                = local.tags
  resource_group_name = azurerm_resource_group.redcap.name
  location            = azurerm_resource_group.redcap.location

  depends_on = [
    azurerm_role_assignment.deployer_can_administrate_kv
  ]
}
