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
  keyvault_name       = azurerm_key_vault.redcap.name
  app_service_plan_id = azurerm_service_plan.redcap.id
  acr_id              = azurerm_container_registry.redcap.id
  app_insights_name   = azurerm_application_insights.redcap.name
  deployers_ip        = local.deployers_ip
  debug               = var.debug
  redcap_image_path   = var.redcap_image_path
  subnets = {
    shared = azurerm_subnet.shared
    webapp = azurerm_subnet.webapp
    mysql  = azurerm_subnet.mysql
  }
  dns_zones = {
    for name, _ in local.dns_zones : name => azurerm_private_dns_zone.all[name]
  }

  depends_on = [
    azurerm_role_assignment.deployer_can_administrate_kv,
    azurerm_private_dns_zone_virtual_network_link.all,
    azurerm_service_plan.redcap
  ]
}
