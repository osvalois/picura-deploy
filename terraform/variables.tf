# terraform/variables.tf
variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  default     = "picura-rg"
}

variable "location" {
  description = "Azure region to deploy resources"
  type        = string
  default     = "East US"
}

variable "cert_manager_email" {
  description = "Email address for Let's Encrypt notifications"
  type        = string
  default     = "a@picura.online"
}

variable "acr_name" {
  description = "Name of the Azure Container Registry"
  type        = string
  default     = "picuraacr"
}

variable "address_space" {
  description = "Address space for the virtual network"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "subnet_prefixes" {
  description = "Subnet prefixes"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "subnet_names" {
  description = "Subnet names"
  type        = list(string)
  default     = ["aks", "apps", "data"]
}

variable "cluster_name" {
  description = "Name of the AKS cluster"
  type        = string
  default     = "picura-aks"
}

variable "kubernetes_version" {
  description = "Kubernetes version"
  type        = string
  default     = "1.21.2"
}

variable "default_node_pool_vm_size" {
  description = "VM size for the default node pool"
  type        = string
  default     = "Standard_DS2_v2"
}

variable "default_node_pool_node_count" {
  description = "Number of nodes in the default node pool"
  type        = number
  default     = 3
}

variable "additional_node_pools" {
  description = "Additional node pools"
  type = map(object({
    vm_size    = string
    node_count = number
    min_count  = number
    max_count  = number
  }))
  default = {
    "gpu" = {
      vm_size    = "Standard_NC6s_v3"
      node_count = 1
      min_count  = 1
      max_count  = 3
    }
  }
}

variable "key_vault_name" {
  description = "Name of the Azure Key Vault"
  type        = string
  default     = "picura-key-vault"
}

variable "log_analytics_workspace_name" {
  description = "Name of the Log Analytics workspace"
  type        = string
  default     = "picura-logs"
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default = {
    Environment = "Production"
    Project     = "Picura"
  }
}
