$ErrorActionPreference = "Stop"
$Version = "v1.9.1"
Write-Host "Installing Envoy Gateway $Version (includes Gateway API CRDs)..."
kubectl apply --server-side -f "https://github.com/envoyproxy/gateway/releases/download/$Version/install.yaml"
Write-Host "Waiting for Envoy Gateway..."
kubectl wait --timeout=5m -n envoy-gateway-system deployment/envoy-gateway --for=condition=Available
Write-Host "Envoy Gateway is ready."
