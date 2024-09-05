# modules/cert_manager/variables.tf

variable "cluster_name" {
  description = "Name of the AKS cluster"
  type        = string
}

variable "email" {
  description = "Email address for Let's Encrypt notifications"
  type        = string
}

variable "cert_manager_version" {
  description = "Version of cert-manager to install"
  type        = string
  default     = "v1.8.0"
}