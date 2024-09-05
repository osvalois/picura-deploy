# modules/kubeflow/variables.tf

variable "cluster_name" {
  description = "Name of the AKS cluster"
  type        = string
}

variable "kubeflow_version" {
  description = "Version of Kubeflow to install"
  type        = string
  default     = "1.5.1"
}

variable "domain" {
  description = "Domain for Kubeflow ingress"
  type        = string
}