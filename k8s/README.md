# Kubernetes demo path (Docker Desktop)

This directory deploys the same distributed-tracing demo used by Docker Compose into Kubernetes.
The primary target is Docker Desktop Kubernetes on Windows, but the manifests are standard Kubernetes YAML.

## Prerequisites

- Docker Desktop running
- Kubernetes enabled in Docker Desktop
- `docker`, `kubectl`, and Docker Compose available
- Current kubectl context points to the intended local cluster

Check:

```powershell
docker version
kubectl version --client
kubectl config current-context
kubectl get nodes
```

For Docker Desktop, the context is normally `docker-desktop`.

## 1. Build the three local images

From the repository root:

```powershell
docker build -t andela-gateway:latest .\gateway
docker build -t andela-order-service:latest .\order-service
docker build -t andela-recommendation-service:latest .\recommendation-service
```

The application deployments use `imagePullPolicy: Never` so the demo does not require a registry when the Kubernetes node can see Docker Desktop's local image store.

## 2. Deploy

```powershell
kubectl apply -k .\k8s
```

Wait for all deployments:

```powershell
kubectl rollout status deployment/jaeger -n andela-demo --timeout=120s
kubectl rollout status deployment/otel-collector -n andela-demo --timeout=120s
kubectl rollout status deployment/recommendation-service -n andela-demo --timeout=120s
kubectl rollout status deployment/order-service -n andela-demo --timeout=120s
kubectl rollout status deployment/gateway -n andela-demo --timeout=120s
kubectl get pods -n andela-demo
```

Expected: five pods are `Running` and application pods become `Ready`.

## 3. Expose the demo locally

Terminal A:

```powershell
kubectl port-forward -n andela-demo service/gateway 8080:8080
```

Terminal B:

```powershell
kubectl port-forward -n andela-demo service/jaeger 16686:16686
```

Keep both terminals open.

Open:

- Demo UI: `http://localhost:8080`
- Jaeger UI: `http://localhost:16686`

## 4. Generate a slow request

Use the UI and click **Place Demo Order**, or in another terminal:

```powershell
curl.exe http://localhost:8080/api/order
```

The request intentionally takes about 3 seconds.

Generate several traces:

```powershell
1..5 | ForEach-Object { curl.exe http://localhost:8080/api/order }
```

## 5. Find the bottleneck in Jaeger

1. Open `http://localhost:16686`.
2. Select service `gateway`.
3. Click **Find Traces**.
4. Open the latest trace.
5. Follow `gateway -> order-service -> recommendation-service`.
6. Find `slow-external-dependency`.
7. Show its duration (~3 seconds) and attributes such as `demo.delay_seconds=3.0`.

## 6. Kubernetes-specific observability commands

```powershell
kubectl get pods -n andela-demo -o wide
kubectl get svc -n andela-demo
kubectl logs -n andela-demo deployment/gateway --tail=100
kubectl logs -n andela-demo deployment/order-service --tail=100
kubectl logs -n andela-demo deployment/recommendation-service --tail=100
kubectl logs -n andela-demo deployment/otel-collector --tail=100
kubectl describe pod -n andela-demo <POD_NAME>
```

## 7. Live experiment: increase latency to 6 seconds

```powershell
kubectl set env deployment/recommendation-service -n andela-demo DELAY_SECONDS=6.0
kubectl rollout status deployment/recommendation-service -n andela-demo
curl.exe http://localhost:8080/api/order
```

Refresh Jaeger and compare the new trace. The same `slow-external-dependency` span should now be roughly 6 seconds.

Reset to 3 seconds:

```powershell
kubectl set env deployment/recommendation-service -n andela-demo DELAY_SECONDS=3.0
kubectl rollout status deployment/recommendation-service -n andela-demo
```

## 8. If you see ErrImageNeverPull

Check:

```powershell
kubectl get pods -n andela-demo
kubectl describe pod -n andela-demo <POD_NAME>
docker images | Select-String andela
```

`ErrImageNeverPull` means the Kubernetes node cannot see the images built in the host Docker image store. Docker Desktop configurations can differ. For the most portable GitHub reproduction, push the three application images to a registry and replace the three `image:` values in `k8s/app.yaml`, then change `imagePullPolicy` to `IfNotPresent`.

This fallback is only needed when local images are not visible to the Kubernetes node.

## 9. Cleanup

```powershell
kubectl delete -k .\k8s
```

Or:

```powershell
.\WINDOWS_KUBERNETES_CLEANUP.ps1
```
