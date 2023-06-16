resource "azurerm_virtual_network" "redcap" {
  name                = "vnet-${var.suffix}"
  resource_group_name = azurerm_resource_group.redcap.name
  location            = azurerm_resource_group.redcap.location
  address_space       = [local.vnet_address_space]
  tags                = local.tags
}

resource "azurerm_network_security_group" "redcap" {
  name                = "nsg-${var.suffix}"
  resource_group_name = azurerm_resource_group.redcap.name
  location            = azurerm_resource_group.redcap.location
  tags                = local.tags
}

resource "azurerm_subnet" "shared" {
  name                 = "subnet-shared-${var.suffix}"
  resource_group_name  = azurerm_resource_group.redcap.name
  virtual_network_name = azurerm_virtual_network.redcap.name
  address_prefixes     = [local.shared_address_space]
}

resource "azurerm_subnet" "webapp" {
  name                 = "subnet-webapp-${var.suffix}"
  resource_group_name  = azurerm_resource_group.redcap.name
  virtual_network_name = azurerm_virtual_network.redcap.name
  address_prefixes     = [local.webapp_address_space]

  delegation {
    name = "web-app-vnet-integration"

    service_delegation {
      name    = "Microsoft.Web/serverFarms"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }

  service_endpoints = [
    "Microsoft.KeyVault"
  ]
}

resource "azurerm_subnet" "mysql" {
  name                 = "subnet-mysql-${var.suffix}"
  resource_group_name  = azurerm_resource_group.redcap.name
  virtual_network_name = azurerm_virtual_network.redcap.name
  address_prefixes     = [local.mysql_address_space]
  service_endpoints    = ["Microsoft.Storage"]

  delegation {
    name = "mysql-vnet-integration"
    service_delegation {
      name = "Microsoft.DBforMySQL/flexibleServers"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
      ]
    }
  }
}

resource "azurerm_subnet_network_security_group_association" "redcap" {
  for_each = {
    for i, subnet in [azurerm_subnet.shared, azurerm_subnet.webapp] : subnet.name => subnet.id
  }
  subnet_id                 = each.value
  network_security_group_id = azurerm_network_security_group.redcap.id
}

resource "azurerm_private_dns_zone" "all" {
  for_each            = local.dns_zones
  name                = each.value
  resource_group_name = azurerm_resource_group.redcap.name
  tags                = local.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "all" {
  for_each              = local.dns_zones
  name                  = "vnl-${each.key}-${var.suffix}"
  resource_group_name   = azurerm_resource_group.redcap.name
  private_dns_zone_name = each.value
  virtual_network_id    = azurerm_virtual_network.redcap.id

  depends_on = [azurerm_private_dns_zone.all]
}
