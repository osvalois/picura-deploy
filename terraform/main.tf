# terraform/main.tf

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

module "networking" {
  source              = "./modules/networking"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  address_space       = var.address_space
  subnet_prefixes     = var.subnet_prefixes
  subnet_names        = var.subnet_names
  tags                = var.tags
}

module "monitoring" {
  source                       = "./modules/monitoring"
  resource_group_name          = azurerm_resource_group.rg.name
  location                     = azurerm_resource_group.rg.location
  log_analytics_workspace_name = var.log_analytics_workspace_name
  tags                         = var.tags
}

module "aks" {
  source                       = "./modules/aks"
  resource_group_name          = azurerm_resource_group.rg.name
  location                     = azurerm_resource_group.rg.location
  cluster_name                 = var.cluster_name
  kubernetes_version           = var.kubernetes_version
  vnet_subnet_id               = module.networking.subnet_ids["aks"]
  default_node_pool_vm_size    = var.default_node_pool_vm_size
  default_node_pool_node_count = var.default_node_pool_node_count
  additional_node_pools        = var.additional_node_pools
  log_analytics_workspace_id   = module.monitoring.log_analytics_workspace_id
  tags                         = var.tags
}

module "acr" {
  source              = "./modules/acr"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  acr_name            = var.acr_name
  sku                 = "Premium"
  tags                = var.tags
}

module "key_vault" {
  source              = "./modules/key_vault"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  key_vault_name      = var.key_vault_name
  aks_principal_id    = module.aks.principal_id
  tags                = var.tags
}

module "istio" {
  source       = "./modules/istio"
  cluster_name = module.aks.cluster_name
  depends_on   = [module.aks]
}

module "cert_manager" {
  source       = "./modules/cert_manager"
  cluster_name = module.aks.cluster_name
  email        = var.cert_manager_email
  depends_on   = [module.aks]
}

module "kubeflow" {
  source       = "./modules/kubeflow"
  cluster_name = module.aks.cluster_name
  depends_on   = [module.aks, module.istio]
}