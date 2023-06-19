resource "azurerm_public_ip" "example" {
  name                = "example-pip"
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"    
}

# since these variables are re-used - a locals block makes this more maintainable
locals {
  backend_address_pool_name      = "awg-${var.suffix_short}-beap"
  frontend_port_name             = "awg-${var.suffix_short}-feport"
  frontend_ip_configuration_name = "awg-${var.suffix_short}-feip"
  http_setting_name              = "awg-${var.suffix_short}-be-htst"
  listener_name                  = "awg-${var.suffix_short}-httplstn"
  request_routing_rule_name      = "awg-${var.suffix_short}-rqrt"
  redirect_configuration_name    = "awg-${var.suffix_short}-rdrcfg"
}

resource "azurerm_application_gateway" "network" {
  name                = "awg-${var.suffix}"
  resource_group_name = var.resource_group_name
  location            = var.location

  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 1
  }

  gateway_ip_configuration {
    name      = "my-gateway-ip-configuration"
    subnet_id = var.subnets["agw"].id
  }

  frontend_port {
    name = local.frontend_port_name
    port = 80
  }

  frontend_ip_configuration {
    name                 = local.frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.example.id
  }

  backend_address_pool {
    name = local.backend_address_pool_name

    fqdns = [azurerm_linux_web_app.redcap.default_hostname]
  }

  backend_http_settings {
    name                  = local.http_setting_name
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 60
  }

  http_listener {
    name                           = local.listener_name
    frontend_ip_configuration_name = local.frontend_ip_configuration_name
    frontend_port_name             = local.frontend_port_name
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = local.request_routing_rule_name
    rule_type                  = "Basic"
    priority                   = 100
    http_listener_name         = local.listener_name
    backend_address_pool_name  = local.backend_address_pool_name
    backend_http_settings_name = local.http_setting_name
  }
}