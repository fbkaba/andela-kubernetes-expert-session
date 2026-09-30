$ErrorActionPreference = "Stop"

Write-Host "== Containers ==" -ForegroundColor Cyan
docker compose ps

Write-Host "`n== Generate a traced request ==" -ForegroundColor Cyan
curl.exe -fsS http://localhost:8080/api/order

Write-Host "`n`n== HTTP readiness ==" -ForegroundColor Cyan
curl.exe -fsS http://localhost:9090/-/ready
curl.exe -fsS http://localhost:3100/ready
curl.exe -fsS http://localhost:3000/api/health
curl.exe -fsS http://localhost:16686/ | Out-Null
Write-Host "Jaeger UI: OK"

Write-Host "`n== Alloy recent logs ==" -ForegroundColor Cyan
docker compose logs --tail=30 alloy

Write-Host "`n== OTel Collector / Jaeger recent logs ==" -ForegroundColor Cyan
docker compose logs --tail=30 otel-collector jaeger

Write-Host "`nOpen:" -ForegroundColor Green
Write-Host "  Grafana: http://localhost:3000"
Write-Host "  Jaeger : http://localhost:16686"
Write-Host "  Alloy  : http://localhost:12345"
