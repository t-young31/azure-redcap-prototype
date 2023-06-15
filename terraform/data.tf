data "azurerm_client_config" "current" {}

data "http" "deployers_ip" {
  count = var.debug ? 1 : 0
  url   = "http://ifconfig.me"
}
