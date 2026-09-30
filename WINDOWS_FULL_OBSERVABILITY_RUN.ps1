$ErrorActionPreference = "Stop"
Write-Host "=== Andela Full Observability Demo ==="
docker compose up --build -d
docker compose ps
Write-Host "Demo:       http://localhost:8080"
Write-Host "Grafana:    http://localhost:3000"
Write-Host "Jaeger:     http://localhost:16686"
Write-Host "Prometheus: http://localhost:9090"
Write-Host "Alloy:      http://localhost:12345"
