$ErrorActionPreference = "Stop"
Write-Host "=== Andela Optional Kubernetes Gateway API Demo ==="
Write-Host "1/4 Building local images..."
docker build -t andela-gateway:latest .\gateway
docker build -t andela-order-service:latest .\order-service
docker build -t andela-recommendation-service:latest .\recommendation-service
Write-Host "2/4 Deploying core demo..."
kubectl apply -k .\k8s
kubectl wait --timeout=180s -n andela-demo --for=condition=Available deployment/gateway deployment/order-service deployment/recommendation-service deployment/otel-collector deployment/jaeger
Write-Host "3/4 Installing Envoy Gateway if needed..."
if (-not (kubectl get deployment envoy-gateway -n envoy-gateway-system --ignore-not-found -o name)) {
  .\INSTALL_ENVOY_GATEWAY.ps1
}
Write-Host "4/4 Applying GatewayClass, Gateway and HTTPRoute..."
kubectl apply -k .\k8s\optional\gateway-api
kubectl wait --timeout=180s -n andela-demo --for=condition=Programmed gateway/andela-gateway
Write-Host ""
Write-Host "Gateway API resources:"
kubectl get gateway,httproute -n andela-demo
Write-Host ""
Write-Host "Jaeger still uses: kubectl port-forward -n andela-demo service/jaeger 16686:16686"
Write-Host "For a reliable local edge path, port-forward the Envoy service as described in k8s/optional/gateway-api/README.md."
