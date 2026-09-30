# Alloy + Jaeger fix (v1.3)

## What changed

- Alloy was updated to v1.19.2 and its configuration was rewritten using valid multiline Alloy syntax and persistent `--storage.path`.
- Docker discovery refreshes every 5 seconds and keeps Compose `service`, container and project labels.
- Alloy writes Docker logs to `http://loki:3100/loki/api/v1/push`.
- Jaeger v1 was replaced with Jaeger v2.21.0.
- Jaeger OTLP ports 4317/4318 are internal-only. This avoids a host-port collision with the OpenTelemetry Collector, which remains the public OTLP entry point.
- OTel Collector still exports traces to `jaeger:4317` over the Compose network.

## Clean restart on Windows / PowerShell

```powershell
docker compose down -v --remove-orphans
docker compose pull
docker compose up --build -d
docker compose ps
```

Then verify:

```powershell
.\WINDOWS_VERIFY_OBSERVABILITY.ps1
```

## Expected path

```text
Applications -> OTLP HTTP -> OTel Collector :4318 -> OTLP gRPC -> Jaeger :4317
Docker logs  -> Alloy -> Loki -> Grafana
```

If Alloy still fails, inspect:

```powershell
docker compose logs --tail=100 alloy loki
```

If traces do not appear in Jaeger, inspect:

```powershell
docker compose logs --tail=100 otel-collector jaeger
curl.exe http://localhost:8080/api/order
```
