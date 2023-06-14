resource "azurerm_resource_group" "redcap" {
  name     = "rg-${var.suffix}"
  location = local.location

  tags = {
    source = ""
  }
}
