locals {
  tags = {
    source = "https://github.com/t-young31/azure-redcap-prototype"
  }
  location     = "uksouth"
  suffix_short = substr(replace(replace(var.suffix, "-", ""), "_", ""), 0, 17)
  deployers_ip = var.debug ? data.http.deployers_ip[0].response_body : null

  vnet_address_space    = "10.0.0.0/25"
  subnet_address_spaces = cidrsubnets(local.vnet_address_space, 4, 4, 4, 4)
  shared_address_space  = local.subnet_address_spaces[0]
  webapp_address_space  = local.subnet_address_spaces[1]
  mysql_address_space   = local.subnet_address_spaces[2]
  agw_address_space     = local.subnet_address_spaces[3]
  dns_zones = {
    blob     = "privatelink.blob.core.windows.net"
    file     = "privatelink.file.core.windows.net"
    mysql    = "privatelink.mysql.database.azure.com"
    keyvault = "privatelink.vaultcore.azure.net"
    webapp   = "privatelink.azurewebsites.net"
  }
}
