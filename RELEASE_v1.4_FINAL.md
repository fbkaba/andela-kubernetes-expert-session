# Andela Distributed Tracing Demo v1.4 FINAL

Final session package for **Distributed Tracing: Identifying Network Latency Bottlenecks**.

## Validated fixes
- Kubernetes observability kustomization includes Prometheus, Loki, Alloy and Grafana.
- Grafana multi-document YAML separator fixed.
- Alloy Kubernetes River configuration uses valid multiline blocks.
- Alloy RBAC can list/watch pods and read pod logs.
- Kubernetes pod label `app` is promoted to Loki label `service`.
- OTel Collector listens on 0.0.0.0:4317/4318.
- Applications export OTLP/HTTP traces to the collector.
- Jaeger all-in-one 1.62.0 with OTLP enabled in both Compose and Kubernetes.
- Python dependencies pin setuptools==80.9.0.

## Demo query
`{service=~"gateway|order-service|recommendation-service"}`
