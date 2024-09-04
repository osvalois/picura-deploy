# Makefile for Kubernetes Cluster Management

# Variables
KUBECTL = kubectl
HELM = helm
KUSTOMIZE = kustomize

# Namespaces
MONITORING_NS = monitoring
LOGGING_NS = logging

# Monitoring tools
PROMETHEUS_CHART = prometheus-community/kube-prometheus-stack
GRAFANA_CHART = grafana/grafana

# Logging tools
ELK_CHART = elastic/elasticsearch

# Resource management tools
METRICS_SERVER_CHART = metrics-server/metrics-server

# Grafana credentials
GRAFANA_ADMIN_USER ?= $(shell echo $${GRAFANA_ADMIN_USER:-picura})
GRAFANA_ADMIN_PASSWORD ?= $(shell echo $${GRAFANA_ADMIN_PASSWORD:-picuraadm#4?!8})

.PHONY: all install-monitoring install-logging install-resource-management apply-resource-quotas apply-limit-ranges install-hpa install-vpa expose-services get-service-urls clean show-resource-usage update-charts help

all: install-monitoring install-logging install-resource-management apply-resource-quotas apply-limit-ranges install-hpa install-vpa

# Monitoring
install-monitoring:
	$(KUBECTL) create namespace $(MONITORING_NS) --dry-run=client -o yaml | $(KUBECTL) apply -f -
	$(HELM) repo add prometheus-community https://prometheus-community.github.io/helm-charts
	$(HELM) repo add grafana https://grafana.github.io/helm-charts
	$(HELM) repo update
	$(HELM) upgrade --install prometheus $(PROMETHEUS_CHART) -n $(MONITORING_NS)
	$(HELM) upgrade --install grafana $(GRAFANA_CHART) -n $(MONITORING_NS) \
		--set adminUser="$(GRAFANA_ADMIN_USER)" \
		--set adminPassword="$(GRAFANA_ADMIN_PASSWORD)"

# Logging
install-logging:
	$(KUBECTL) create namespace $(LOGGING_NS) --dry-run=client -o yaml | $(KUBECTL) apply -f -
	$(HELM) repo add elastic https://helm.elastic.co
	$(HELM) repo update
	$(HELM) upgrade --install elasticsearch $(ELK_CHART) -n $(LOGGING_NS)
	$(HELM) upgrade --install kibana elastic/kibana -n $(LOGGING_NS)

# Resource Management
install-resource-management:
	$(HELM) repo add metrics-server https://kubernetes-sigs.github.io/metrics-server/
	$(HELM) repo update
	$(HELM) upgrade --install metrics-server $(METRICS_SERVER_CHART) --namespace kube-system

# Apply Resource Quotas
apply-resource-quotas:
	$(KUBECTL) apply -f resource-quota.yaml

# Apply Limit Ranges
apply-limit-ranges:
	$(KUBECTL) apply -f limit-range.yaml

# Install Horizontal Pod Autoscaler
install-hpa:
	$(KUBECTL) apply -f hpa.yaml

# Install Vertical Pod Autoscaler
install-vpa:
	$(HELM) repo add fairwinds-stable https://charts.fairwinds.com/stable
	$(HELM) upgrade --install vpa fairwinds-stable/vpa --namespace kube-system

# Expose services
expose-services:
	$(KUBECTL) patch svc prometheus-kube-prometheus-prometheus -n $(MONITORING_NS) -p '{"spec": {"type": "LoadBalancer"}}'
	$(KUBECTL) patch svc prometheus-grafana -n $(MONITORING_NS) -p '{"spec": {"type": "LoadBalancer"}}'
	$(KUBECTL) patch svc elasticsearch-master -n $(LOGGING_NS) -p '{"spec": {"type": "LoadBalancer"}}'
	$(KUBECTL) patch svc kibana-kibana -n $(LOGGING_NS) -p '{"spec": {"type": "LoadBalancer"}}'
	$(KUBECTL) patch svc metrics-server -n kube-system -p '{"spec": {"type": "LoadBalancer"}}'

# Get service URLs
get-service-urls:
	@echo "Prometheus URL: http://$$($(KUBECTL) get svc prometheus-kube-prometheus-prometheus -n $(MONITORING_NS) -o jsonpath='{.status.loadBalancer.ingress[0].ip}'):9090"
	@echo "Grafana URL: http://$$($(KUBECTL) get svc prometheus-grafana -n $(MONITORING_NS) -o jsonpath='{.status.loadBalancer.ingress[0].ip}'):80"
	@echo "Elasticsearch URL: http://$$($(KUBECTL) get svc elasticsearch-master -n $(LOGGING_NS) -o jsonpath='{.status.loadBalancer.ingress[0].ip}'):9200"
	@echo "Kibana URL: http://$$($(KUBECTL) get svc kibana-kibana -n $(LOGGING_NS) -o jsonpath='{.status.loadBalancer.ingress[0].ip}'):5601"
	@echo "Metrics Server API: https://$$($(KUBECTL) get svc metrics-server -n kube-system -o jsonpath='{.status.loadBalancer.ingress[0].ip}'):443/apis/metrics.k8s.io/v1beta1/"

# Clean up
clean:
	$(HELM) uninstall prometheus -n $(MONITORING_NS)
	$(HELM) uninstall grafana -n $(MONITORING_NS)
	$(HELM) uninstall elasticsearch -n $(LOGGING_NS)
	$(HELM) uninstall kibana -n $(LOGGING_NS)
	$(HELM) uninstall metrics-server --namespace kube-system
	$(HELM) uninstall vpa --namespace kube-system
	$(KUBECTL) delete namespace $(MONITORING_NS)
	$(KUBECTL) delete namespace $(LOGGING_NS)

# Show cluster resource usage
show-resource-usage:
	$(KUBECTL) top nodes
	$(KUBECTL) top pods --all-namespaces

# Update all Helm charts
update-charts:
	$(HELM) repo update
	$(HELM) upgrade --install prometheus $(PROMETHEUS_CHART) -n $(MONITORING_NS)
	$(HELM) upgrade --install grafana $(GRAFANA_CHART) -n $(MONITORING_NS) \
		--set adminUser="$(GRAFANA_ADMIN_USER)" \
		--set adminPassword="$(GRAFANA_ADMIN_PASSWORD)"
	$(HELM) upgrade --install elasticsearch $(ELK_CHART) -n $(LOGGING_NS)
	$(HELM) upgrade --install kibana elastic/kibana -n $(LOGGING_NS)
	$(HELM) upgrade --install metrics-server $(METRICS_SERVER_CHART) --namespace kube-system
	$(HELM) upgrade --install vpa fairwinds-stable/vpa --namespace kube-system

# Help
help:
	@echo "Available targets:"
	@echo "  all                         - Install all components"
	@echo "  install-monitoring          - Install Prometheus and Grafana for monitoring"
	@echo "  install-logging             - Install ELK stack for logging"
	@echo "  install-resource-management - Install Metrics Server"
	@echo "  apply-resource-quotas       - Apply Resource Quotas"
	@echo "  apply-limit-ranges          - Apply Limit Ranges"
	@echo "  install-hpa                 - Install Horizontal Pod Autoscaler"
	@echo "  install-vpa                 - Install Vertical Pod Autoscaler"
	@echo "  expose-services             - Expose services as LoadBalancer"
	@echo "  get-service-urls            - Get URLs for exposed services"
	@echo "  clean                       - Remove all installed components"
	@echo "  show-resource-usage         - Display current resource usage"
	@echo "  update-charts               - Update all Helm charts"
	@echo "  help                        - Show this help message"
	@echo ""
	@echo "Grafana credentials are set using environment variables:"
	@echo "  GRAFANA_ADMIN_USER  (default: picura)"
	@echo "  GRAFANA_ADMIN_PASSWORD  (default: picuraadm#4?!8)"