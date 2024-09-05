# modules/istio/outputs.tf

output "namespace" {
  value = kubernetes_namespace.istio_system.metadata[0].name
}

output "gateway_name" {
  value = kubernetes_manifest.istio_gateway.manifest.metadata.name
}