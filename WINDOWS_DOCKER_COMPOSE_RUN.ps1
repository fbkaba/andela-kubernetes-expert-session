$ErrorActionPreference = "Stop"
Write-Host "=== Andela Distributed Tracing Demo ==="
Write-Host "Building and starting the stack..."
docker compose up --build -d
Write-Host ""
docker compose ps
Write-Host ""
Write-Host "Demo UI:   http://localhost:8080"
Write-Host "Jaeger UI: http://localhost:16686"
Write-Host ""
Write-Host "Generate a trace by clicking 'Place Demo Order' in the Demo UI."
Write-Host "To follow logs: docker compose logs -f"
Write-Host "To stop:        docker compose down"
