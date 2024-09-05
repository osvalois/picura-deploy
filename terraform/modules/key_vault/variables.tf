variable "resource_group_name" {
  description = "The name of the resource group in which to create the Key Vault"
  type        = string
}

variable "location" {
  description = "The location/region where the Key Vault is created"
  type        = string
}

variable "key_vault_name" {
  description = "The name of the Key Vault"
  type        = string
}

variable "aks_principal_id" {
  description = "The principal ID of the AKS cluster"
  type        = string
}

variable "tags" {
  description = "A mapping of tags to assign to the resource"
  type        = map(string)
  default     = {}
}