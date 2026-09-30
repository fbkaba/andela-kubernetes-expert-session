$ErrorActionPreference = "Stop"

Write-Host "=== Andela Distributed Tracing - Kubernetes Demo ===" -ForegroundColor Cyan
Write-Host "Context:" (kubectl config current-context)

if ((kubectl config current-context) -notmatch "docker-desktop") {
  Write-Warning "Current context is not docker-desktop. Confirm this is the cluster you want to use."
}

Write-Host "`n[1/5] Building local application images..." -ForegroundColor Yellow
docker build -t andela-gateway:latest .\gateway
docker build -t andela-order-service:latest .\order-service
docker build -t andela-recommendation-service:latest .\recommendation-service

Write-Host "`n[2/5] Applying Kubernetes resources..." -ForegroundColor Yellow
kubectl apply -k .\k8s

Write-Host "`n[3/5] Waiting for workloads..." -ForegroundColor Yellow
kubectl rollout status deployment/jaeger -n andela-demo --timeout=120s
kubectl rollout status deployment/otel-collector -n andela-demo --timeout=120s
kubectl rollout status deployment/recommendation-service -n andela-demo --timeout=120s
kubectl rollout status deployment/order-service -n andela-demo --timeout=120s
kubectl rollout status deployment/gateway -n andela-demo --timeout=120s

Write-Host "`n[4/5] Current resources:" -ForegroundColor Yellow
kubectl get pods,svc -n andela-demo

Write-Host "`n[5/5] Start these in TWO additional terminals:" -ForegroundColor Yellow
Write-Host "kubectl port-forward -n andela-demo service/gateway 8080:8080"
Write-Host "kubectl port-forward -n andela-demo service/jaeger 16686:16686"
Write-Host "`nThen open http://localhost:8080 and http://localhost:16686" -ForegroundColor Green
Write-Host "If a pod shows ErrImageNeverPull, see k8s/README.md for the local-image fallback." -ForegroundColor Magenta
