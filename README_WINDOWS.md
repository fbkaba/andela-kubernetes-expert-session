# Andela Distributed Tracing Demo — Windows / Docker Desktop

## Fastest path: Docker Compose
From PowerShell in this directory:

```powershell
.\WINDOWS_DOCKER_COMPOSE_RUN.ps1
```

Gateway: http://localhost:8080
Jaeger: http://localhost:16686

Generate traffic using the endpoint documented in `demo-commands.sh`.

## Kubernetes on Docker Desktop — no registry required
Ensure Docker Desktop Kubernetes is enabled and `kubectl config current-context` points to `docker-desktop`.
Then run:

```powershell
.\WINDOWS_DEMO_RUN.ps1
```

The Kubernetes manifests use locally built images with `imagePullPolicy: Never`, so `YOUR_REGISTRY` is no longer required.

Open two additional PowerShell terminals:

```powershell
kubectl port-forward svc/gateway 8080:8080
```

```powershell
kubectl port-forward svc/jaeger 16686:16686
```

Then generate demo traffic using `demo-commands.sh` (or the equivalent PowerShell request).

## Fixes included
- `setuptools<81` in all three Python services, restoring `pkg_resources` required by the pinned OpenTelemetry instrumentation.
- OTLP Collector receivers explicitly bind to `0.0.0.0:4317` and `0.0.0.0:4318` so other containers/pods can reach them.
- Kubernetes app images are local (`andela-*:latest`) with `imagePullPolicy: Never`.
- PowerShell scripts added for repeatable Windows demo startup.
