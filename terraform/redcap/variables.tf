variable "suffix" {}
variable "suffix_short" {}
variable "resource_group_name" {}
variable "location" {}
variable "keyvault_id" {}
variable "storage_account_key" {
  type      = string
  sensitive = true
}
variable "tags" {
  type = map(any)
}
variable "subnets" {
  type = map
}
