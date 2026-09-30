$ErrorActionPreference = "Stop"
Write-Host "Building local demo images..."
docker build --no-cache -t andela-gateway:latest .\gateway
docker build --no-cache -t andela-order-service:latest .\order-service
docker build --no-cache -t andela-recommendation-service:latest .\recommendation-service
Write-Host "Images built. Deploying to current Kubernetes context..."
kubectl apply -f .\k8s\jaeger.yaml
kubectl apply -f .\k8s\otel-collector.yaml
kubectl apply -f .\k8s\app.yaml
kubectl rollout status deployment/jaeger --timeout=120s
kubectl rollout status deployment/otel-collector --timeout=120s
kubectl rollout status deployment/recommendation-service --timeout=120s
kubectl rollout status deployment/order-service --timeout=120s
kubectl rollout status deployment/gateway --timeout=120s
kubectl get pods
Write-Host "Ready. In terminal 1: kubectl port-forward svc/gateway 8080:8080"
Write-Host "In terminal 2: kubectl port-forward svc/jaeger 16686:16686"
Write-Host "Then: Invoke-RestMethod http://localhost:8080/checkout"
