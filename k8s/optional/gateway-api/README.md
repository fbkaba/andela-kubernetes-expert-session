# Optional edge demo: Kubernetes Gateway API + Envoy Gateway

This directory is intentionally NOT part of `k8s/kustomization.yaml`. The core demo works without any edge controller. Apply this extension only after Envoy Gateway is installed.

## Why Gateway API instead of ingress-nginx?

For a new 2026 demo, Gateway API is the preferred modern Kubernetes routing model. The community ingress-nginx project has been retired; this optional path therefore uses Envoy Gateway and the standard `Gateway` + `HTTPRoute` resources.

## Install Envoy Gateway

Windows PowerShell from the repository root:

```powershell
.\INSTALL_ENVOY_GATEWAY.ps1
```

Equivalent pinned install:

```powershell
kubectl apply --server-side -f https://github.com/envoyproxy/gateway/releases/download/v1.9.1/install.yaml
kubectl wait --timeout=5m -n envoy-gateway-system deployment/envoy-gateway --for=condition=Available
```

## Apply the demo edge resources

```powershell
kubectl apply -k .\k8s\optional\gateway-api
kubectl get gateway,httproute -n andela-demo
```

Wait until `andela-gateway` is Programmed:

```powershell
kubectl wait --timeout=180s -n andela-demo --for=condition=Programmed gateway/andela-gateway
```

## Reliable local access (works even if Docker Desktop does not expose a LoadBalancer address)

Find the Envoy proxy Service created for this Gateway:

```powershell
$envoySvc = kubectl get svc -n envoy-gateway-system -l gateway.envoyproxy.io/owning-gateway-namespace=andela-demo,gateway.envoyproxy.io/owning-gateway-name=andela-gateway -o jsonpath='{.items[0].metadata.name}'
$envoySvc
```

Forward local port 8888 to the Envoy edge proxy:

```powershell
kubectl port-forward -n envoy-gateway-system service/$envoySvc 8888:80
```

Open `http://localhost:8888` or generate traffic with:

```powershell
curl.exe http://localhost:8888/api/order
```

Jaeger remains available via:

```powershell
kubectl port-forward -n andela-demo service/jaeger 16686:16686
```

Open `http://localhost:16686`.

## Request path

Browser -> Envoy Gateway -> HTTPRoute -> gateway Service -> gateway Pod -> order-service -> recommendation-service -> OTel Collector -> Jaeger

The application trace begins at the instrumented Flask gateway. The Envoy edge hop is a real network boundary, but this demo does not claim that Envoy itself appears as an application span unless Envoy tracing is separately configured.

## Cleanup

```powershell
kubectl delete -k .\k8s\optional\gateway-api
```

Optional controller cleanup:

```powershell
kubectl delete -f https://github.com/envoyproxy/gateway/releases/download/v1.9.1/install.yaml
```
