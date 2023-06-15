variable "suffix" {
  type        = string
  description = "Suffix used to uniquley name resources"
}

variable "debug" {
  type    = bool
  default = false
}

variable "acr_name" {
  type        = string
  description = "Name of an azure container registry (ACR) to create"
}

variable "redcap_image_path" {
  type        = string
  description = "Path to the docker image containg the REDCap app. e.g. acryourname.azurecr.io/repository/redcap"
}
