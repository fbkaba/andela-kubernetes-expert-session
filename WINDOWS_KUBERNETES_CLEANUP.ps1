$ErrorActionPreference = "Continue"
kubectl delete -k .\k8s
Write-Host "Andela demo namespace/resources removed." -ForegroundColor Green
