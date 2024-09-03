#!/bin/bash

# Collect URLs
PROMETHEUS_URL=$(kubectl get svc prometheus-kube-prometheus-prometheus -n monitoring -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
GRAFANA_URL=$(kubectl get svc prometheus-grafana -n monitoring -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
ELASTICSEARCH_URL=$(kubectl get svc elasticsearch-master -n logging -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
KIBANA_URL=$(kubectl get svc kibana-kibana -n logging -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
METRICS_SERVER_URL=$(kubectl get svc metrics-server -n kube-system -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

# Create release notes
cat << EOF > release_notes.md
# Service URLs

## Monitoring
- Prometheus: http://${PROMETHEUS_URL}:9090
- Grafana: http://${GRAFANA_URL}:80

## Logging
- Elasticsearch: http://${ELASTICSEARCH_URL}:9200
- Kibana: http://${KIBANA_URL}:5601

## Resource Management
- Metrics Server API: https://${METRICS_SERVER_URL}:443/apis/metrics.k8s.io/v1beta1/

Please note that you may need to use appropriate authentication to access these services.
EOF

# Create GitHub release
gh release create v$(date +%Y.%m.%d) -F release_notes.md -t "Service URLs $(date +%Y-%m-%d)"

# Clean up
rm release_notes.md