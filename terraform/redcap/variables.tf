variable "suffix" {}
variable "suffix_short" {}
variable "resource_group_name" {}
variable "location" {}
variable "debug" {}
variable "keyvault_name" {}
variable "deployers_ip" {}
variable "app_service_plan_id" {}
variable "redcap_image_path" {}
variable "acr_id" {}
variable "app_insights_name" {}
variable "tags" {
  type = map(any)
}
variable "subnets" {
  type = map(any)
}
variable "dns_zones" {
  type = map(any)
}
