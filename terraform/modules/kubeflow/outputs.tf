# modules/kubeflow/outputs.tf

output "namespace" {
  value = kubernetes_namespace.kubeflow.metadata[0].name
}

output "gateway_name" {
  value = kubernetes_manifest.kubeflow_gateway.manifest.metadata.name
}

output "kubeflow_url" {
  value = "http://kubeflow.${var.domain}"
}