# modules/istio/variables.tf

variable "cluster_name" {
  description = "Name of the AKS cluster"
  type        = string
}

variable "istio_version" {
  description = "Version of Istio to install"
  type        = string
  default     = "1.13.3"
}