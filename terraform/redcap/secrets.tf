resource "azurerm_key_vault_secret" "all" {
  for_each     = local.secrets
  name         = each.key
  value        = each.value
  key_vault_id = var.keyvault_id
}
