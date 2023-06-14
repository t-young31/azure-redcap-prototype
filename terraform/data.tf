data "azurerm_client_config" "current" {}

data "http" "ifconfig" {
  url = "http://ifconfig.me"
}
