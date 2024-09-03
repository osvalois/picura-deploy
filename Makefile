# Makefile para conectarse a un clúster de Kubernetes y preparar el entorno

# Variables
KUBECONFIG=picura-kubeconfig.yaml
HELM_VERSION=v3.10.3
KUBECTL_VERSION=v1.26.0

# Comandos
.PHONY: all install_kubectl install_helm connect_k8s

all: connect_k8s

# Instalar kubectl
install_kubectl:
	@echo "Instalando kubectl..."
	@curl -LO "https://storage.googleapis.com/kubernetes-release/release/$(KUBECTL_VERSION)/bin/linux/amd64/kubectl"
	@chmod +x ./kubectl
	@sudo mv ./kubectl /usr/local/bin/kubectl
	@echo "kubectl instalado."

# Instalar helm
install_helm:
	@echo "Instalando Helm..."
	@curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash
	@echo "Helm instalado."

# Conectar al clúster de Kubernetes
connect_k8s: install_kubectl install_helm
	@echo "Configurando el acceso al clúster de Kubernetes..."
	@export KUBECONFIG=$(KUBECONFIG)
	@echo "Conectado al clúster de Kubernetes."

# Limpiar los artefactos
clean:
	@echo "Limpiando..."
	@rm -f kubectl
