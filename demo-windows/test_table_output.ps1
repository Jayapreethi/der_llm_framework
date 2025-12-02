# Test Table Output - Quick Demo
# Shows how the setup.ps1 now displays results in tables

Write-Host "=== SETUP.PS1 TABLE OUTPUT DEMO ===" -ForegroundColor Cyan
Write-Host ""

# Source the helper function
. "$PSScriptRoot\setup.ps1"

Write-Host "Example 1: Health Check (Object as Table)" -ForegroundColor Yellow
Write-Host "=" * 60
Invoke-ApiCall -Url "http://localhost:8000/health" -ShowAsTable

Write-Host "`nExample 2: DER Data (Array as Table - First 5 rows)" -ForegroundColor Yellow
Write-Host "=" * 60
Invoke-ApiCall -Url "http://localhost:7871/data/1min" -ShowAsTable -TimeoutSec 15

Write-Host "`nExample 3: System Metrics (Object as Table)" -ForegroundColor Yellow
Write-Host "=" * 60
Invoke-ApiCall -Url "http://localhost:8000/metrics/system" -ShowAsTable

Write-Host "`nExample 4: Performance Metrics (Object as Table)" -ForegroundColor Yellow
Write-Host "=" * 60
Invoke-ApiCall -Url "http://localhost:8000/metrics/performance" -ShowAsTable

Write-Host "`n=== ALL RESULTS NOW SHOW AS FORMATTED TABLES ===" -ForegroundColor Green
Write-Host ""
Write-Host "The setup.ps1 script now displays all API responses in readable table format!" -ForegroundColor White
Write-Host "- Objects are displayed as Property/Value tables" -ForegroundColor Gray
Write-Host "- Arrays show first 5 records in tabular format" -ForegroundColor Gray
Write-Host "- Complex nested objects are shown as compact JSON" -ForegroundColor Gray
Write-Host ""
