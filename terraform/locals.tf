locals {
  location = "uksouth"

  vnet_address_space    = "10.0.0.0/25"
  subnet_address_spaces = cidrsubnets(local.vnet_address_space, 2, 2)
  shared_address_space  = local.subnet_address_spaces[0]
  webapp_address_space  = local.subnet_address_spaces[1]
}
