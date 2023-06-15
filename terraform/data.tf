data "azurerm_client_config" "current" {}

data "http" "deployers_ip" {
  url = "http://ifconfig.me"
}
