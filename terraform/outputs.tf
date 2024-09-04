# terraform/outputs.tf
output "resource_group_name" {
  value = azurerm_resource_group.rg.name
}

output "kubernetes_cluster_name" {
  value = module.aks.cluster_name
}

output "client_certificate" {
  value     = module.aks.client_certificate
  sensitive = true
}

output "client_key" {
  value     = module.aks.client_key
  sensitive = true
}

output "cluster_ca_certificate" {
  value     = module.aks.cluster_ca_certificate
  sensitive = true
}

output "cluster_password" {
  value     = module.aks.cluster_password
  sensitive = true
}

output "cluster_username" {
  value     = module.aks.cluster_username
  sensitive = true
}

output "host" {
  value     = module.aks.host
  sensitive = true
}

output "kube_config" {
  value     = module.aks.kube_config
  sensitive = true
}

output "key_vault_id" {
  value = module.security.key_vault_id
}

output "log_analytics_workspace_id" {
  value = module.monitoring.log_analytics_workspace_id
}