# modules/kubeflow/main.tf

resource "kubernetes_namespace" "kubeflow" {
  metadata {
    name = "kubeflow"

    labels = {
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }
}

resource "helm_release" "kubeflow" {
  name       = "kubeflow"
  repository = "https://kubeflow.github.io/manifests"
  chart      = "kubeflow"
  version    = var.kubeflow_version
  namespace  = kubernetes_namespace.kubeflow.metadata[0].name

  set {
    name  = "platform"
    value = "aks"
  }

  set {
    name  = "profiles-deployment.enabled"
    value = "true"
  }

  set {
    name  = "jupyter.enabled"
    value = "true"
  }

  set {
    name  = "pipelines.enabled"
    value = "true"
  }

  set {
    name  = "katib.enabled"
    value = "true"
  }

  set {
    name  = "gateway.enabled"
    value = "true"
  }
}

resource "kubernetes_manifest" "kubeflow_gateway" {
  manifest = {
    apiVersion = "networking.istio.io/v1alpha3"
    kind       = "Gateway"
    metadata = {
      name      = "kubeflow-gateway"
      namespace = kubernetes_namespace.kubeflow.metadata[0].name
    }
    spec = {
      selector = {
        istio = "ingressgateway"
      }
      servers = [
        {
          port = {
            number   = 80
            name     = "http"
            protocol = "HTTP"
          }
          hosts = ["kubeflow.${var.domain}"]
        }
      ]
    }
  }
}

resource "kubernetes_manifest" "kubeflow_virtual_service" {
  depends_on = [kubernetes_manifest.kubeflow_gateway]

  manifest = {
    apiVersion = "networking.istio.io/v1alpha3"
    kind       = "VirtualService"
    metadata = {
      name      = "kubeflow-routes"
      namespace = kubernetes_namespace.kubeflow.metadata[0].name
    }
    spec = {
      hosts    = ["kubeflow.${var.domain}"]
      gateways = ["kubeflow-gateway"]
      http = [
        {
          match = [
            {
              uri = {
                prefix = "/"
              }
            }
          ]
          route = [
            {
              destination = {
                host = "kubeflow-gateway.kubeflow.svc.cluster.local"
                port = {
                  number = 80
                }
              }
            }
          ]
        }
      ]
    }
  }
}