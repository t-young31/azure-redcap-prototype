resource "azurerm_virtual_network" "redcap" {
  name                = "vnet-${var.suffix}"
  resource_group_name = azurerm_resource_group.redcap.name
  location            = azurerm_resource_group.redcap.location
  address_space       = [local.vnet_address_space]
}

resource "azurerm_network_security_group" "redcap" {
  name                = "nsg-${var.suffix}"
  resource_group_name = azurerm_resource_group.redcap.name
  location            = azurerm_resource_group.redcap.location
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
}

resource "azurerm_subnet_network_security_group_association" "redcap" {
  for_each = {
    for i, subnet in [azurerm_subnet.shared, azurerm_subnet.webapp] : subnet.name => subnet.id
  }
  subnet_id                 = each.value
  network_security_group_id = azurerm_network_security_group.redcap.id
}
