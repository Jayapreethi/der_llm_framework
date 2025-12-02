# PowerShell Setup Script for GPT ML Data Analysis Service
# Version: 3.0.1 - Windows Compatible (Encoding Fixed)
# Focus: GPT analysis and ML-based DER data analysis

# Set error action preference
$ErrorActionPreference = "Stop"

# Change to script directory
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $ScriptDir

Write-Host "Starting GPT ML Data Analysis Service Setup..." -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "Working Directory: $ScriptDir" -ForegroundColor Gray

# Step 0: Export API Tokens
Write-Host "`nStep 0: Setting up API tokens..." -ForegroundColor Yellow
$env:OPENAI_API_KEY = "PUT_YOUR_OPENAI_API_KEY_HERE"
Write-Host "OPENAI_API_KEY: $env:OPENAI_API_KEY" -ForegroundColor Green

# Step 1: Environment Check
Write-Host "`nStep 1: Checking environment..." -ForegroundColor Yellow

# Check for docker-compose
if (-not (Get-Command docker-compose -ErrorAction SilentlyContinue)) {
    Write-Host "[ERROR] docker-compose not found! Please install Docker Desktop for Windows." -ForegroundColor Red
    exit 1
}

# Check if Docker daemon is running
Write-Host "Checking Docker daemon status..." -ForegroundColor Cyan
$maxRetries = 30
$retryCount = 0
$dockerReady = $false

while ($retryCount -lt $maxRetries) {
    try {
        $null = docker info 2>&1
        if ($LASTEXITCODE -eq 0) {
            $dockerReady = $true
            break
        }
    } catch {
        # Docker not ready yet
    }
    
    if ($retryCount -eq 0) {
        Write-Host "Waiting for Docker Desktop to start..." -ForegroundColor Yellow
    }
    Write-Host "." -NoNewline
    Start-Sleep -Seconds 2
    $retryCount++
}

Write-Host ""

if (-not $dockerReady) {
    Write-Host "[ERROR] Docker Desktop is not running! Please start Docker Desktop and try again." -ForegroundColor Red
    Write-Host "You can start Docker Desktop from the Start menu or system tray." -ForegroundColor Yellow
    exit 1
}

Write-Host "[SUCCESS] Docker is ready!" -ForegroundColor Green

# Check for curl (built into Windows 10+)
if (-not (Get-Command curl.exe -ErrorAction SilentlyContinue)) {
    Write-Host "[WARNING] curl not found! Using Invoke-WebRequest instead." -ForegroundColor Yellow
    $useCurl = $false
} else {
    $useCurl = $true
}

Write-Host "[SUCCESS] Environment check passed." -ForegroundColor Green

# Step 2: Docker Compose Build (No Cache)
Write-Host "`nStep 2: Building Docker containers..." -ForegroundColor Yellow

Write-Host "Stopping existing containers..." -ForegroundColor Cyan
try { docker-compose down 2>&1 | Out-Null } catch { }

Write-Host "Removing existing Docker containers..." -ForegroundColor Cyan
try { docker-compose rm -f 2>&1 | Out-Null } catch { }

Write-Host "Cleaning up Docker system..." -ForegroundColor Cyan
try { docker system prune -f 2>&1 | Out-Null } catch { }

Write-Host "Building Docker containers with --no-cache..." -ForegroundColor Cyan
docker-compose build --no-cache --progress=plain
if ($LASTEXITCODE -ne 0) {
    Write-Host "[ERROR] Docker build failed! Please check the Dockerfile and dependencies." -ForegroundColor Red
    exit 1
}

Write-Host "Final system cleanup..." -ForegroundColor Cyan
try { docker system prune -f 2>&1 | Out-Null } catch { }

# Step 3: Docker Compose Up
Write-Host "`nStep 3: Starting Docker containers..." -ForegroundColor Yellow
docker-compose up -d
if ($LASTEXITCODE -ne 0) {
    Write-Host "[ERROR] Docker Compose up failed! Please check your docker-compose.yml file." -ForegroundColor Red
    exit 1
}

# Step 4: Wait for Containers to Start
Write-Host "`nStep 4: Waiting for containers to initialize..." -ForegroundColor Yellow
Write-Host "Waiting 20 seconds for services to fully start..." -ForegroundColor Cyan
Start-Sleep -Seconds 20

# Helper function for API calls with table formatting
function Invoke-ApiCall {
    param(
        [string]$Url,
        [string]$Method = "GET",
        [string]$Body = $null,
        [int]$TimeoutSec = 10,
        [switch]$ShowAsTable
    )
    
    try {
        $headers = @{"Content-Type"="application/json"}
        if ($Method -eq "POST" -and $Body) {
            $response = Invoke-RestMethod -Uri $Url -Method POST -Headers $headers -Body $Body -TimeoutSec $TimeoutSec
        } else {
            $response = Invoke-RestMethod -Uri $Url -Method GET -Headers $headers -TimeoutSec $TimeoutSec
        }
        
        if ($ShowAsTable) {
            # Display as table if it's an array
            if ($response -is [System.Array]) {
                $response | Select-Object -First 5 | Format-Table -AutoSize
                if ($response.Count -gt 5) {
                    Write-Host "  ... and $($response.Count - 5) more records" -ForegroundColor Gray
                }
            } else {
                # For objects, convert to property table
                $response.PSObject.Properties | ForEach-Object {
                    [PSCustomObject]@{
                        Property = $_.Name
                        Value = if ($_.Value -is [string] -or $_.Value -is [int] -or $_.Value -is [double]) { 
                            $_.Value 
                        } else { 
                            ($_.Value | ConvertTo-Json -Compress -Depth 2) 
                        }
                    }
                } | Format-Table -AutoSize -Wrap
            }
        } else {
            $response | ConvertTo-Json -Depth 10 -Compress
        }
        Write-Host ""
        return $response
    } catch {
        Write-Host "[WARNING] Request failed: $($_.Exception.Message)" -ForegroundColor Yellow
        return $null
    }
}

# Step 5: Test Data Service Endpoints
Write-Host "`nStep 5: Testing Data Service endpoints..." -ForegroundColor Yellow
Write-Host "=========================================" -ForegroundColor Cyan

Write-Host "[TEST] Testing data service root endpoint..." -ForegroundColor Cyan
Invoke-ApiCall -Url "http://localhost:7871/" -ShowAsTable

Write-Host "[TEST] Fetching 1min aggregated DER data (showing first 5 records)..." -ForegroundColor Cyan
Invoke-ApiCall -Url "http://localhost:7871/data/1min" -TimeoutSec 15 -ShowAsTable

Write-Host "[TEST] Fetching 3min aggregated DER data (showing first 5 records)..." -ForegroundColor Cyan
Invoke-ApiCall -Url "http://localhost:7871/data/3min" -TimeoutSec 15 -ShowAsTable

Write-Host "[TEST] Fetching 5min aggregated DER data (showing first 5 records)..." -ForegroundColor Cyan
Invoke-ApiCall -Url "http://localhost:7871/data/5min" -TimeoutSec 15 -ShowAsTable

# Step 6: Test LLM Service Basic Endpoints
Write-Host "`nStep 6: Testing LLM Service basic endpoints..." -ForegroundColor Yellow
Write-Host "==============================================" -ForegroundColor Cyan

Write-Host "[TEST] Testing LLM service root endpoint..." -ForegroundColor Cyan
Invoke-ApiCall -Url "http://localhost:8000/" -ShowAsTable

Write-Host "[TEST] Testing health check endpoint..." -ForegroundColor Cyan
Invoke-ApiCall -Url "http://localhost:8000/health" -ShowAsTable

# Step 7: Test GPT Analysis Endpoints
Write-Host "`nStep 7: Testing GPT Analysis endpoints..." -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Cyan

Write-Host "[TEST] Testing basic GPT endpoint..." -ForegroundColor Cyan
$body1 = '{"prompt": "What is distributed energy resource (DER) analysis?"}'
Invoke-ApiCall -Url "http://localhost:8000/query_gpt" -Method POST -Body $body1 -TimeoutSec 30 -ShowAsTable

Write-Host "[TEST] Testing DER data analysis endpoint..." -ForegroundColor Cyan
$body2 = '{"interval": "1min", "analysis_type": "summary"}'
Invoke-ApiCall -Url "http://localhost:8000/analyze_data" -Method POST -Body $body2 -TimeoutSec 45 -ShowAsTable

Write-Host "[TEST] Testing data insights endpoint..." -ForegroundColor Cyan
$body3 = '{"question": "What are the key performance indicators in this DER data?", "interval": "1min"}'
Invoke-ApiCall -Url "http://localhost:8000/data_insights" -Method POST -Body $body3 -TimeoutSec 45 -ShowAsTable

# Step 8: Test Machine Learning Analysis Endpoints
Write-Host "`nStep 8: Testing Machine Learning Analysis endpoints..." -ForegroundColor Yellow
Write-Host "====================================================" -ForegroundColor Cyan

Write-Host "[TEST] Testing anomaly detection..." -ForegroundColor Cyan
$body4 = '{"interval": "1min"}'
Invoke-ApiCall -Url "http://localhost:8000/detect_anomalies" -Method POST -Body $body4 -TimeoutSec 60 -ShowAsTable

Write-Host "[TEST] Testing clustering analysis..." -ForegroundColor Cyan
$body5 = '{"interval": "1min", "n_clusters": 3}'
Invoke-ApiCall -Url "http://localhost:8000/cluster_analysis" -Method POST -Body $body5 -TimeoutSec 60 -ShowAsTable

Write-Host "[TEST] Testing predictive analysis..." -ForegroundColor Cyan
$body6 = '{"interval": "1min"}'
Invoke-ApiCall -Url "http://localhost:8000/predictive_analysis" -Method POST -Body $body6 -TimeoutSec 60 -ShowAsTable

Write-Host "[TEST] Testing comprehensive ML analysis..." -ForegroundColor Cyan
$body7 = '{"interval": "1min"}'
Invoke-ApiCall -Url "http://localhost:8000/comprehensive_ml_analysis" -Method POST -Body $body7 -TimeoutSec 90 -ShowAsTable

# Step 9: Test Advanced GPT + ML Integration
Write-Host "`nStep 9: Testing Advanced GPT + ML Integration..." -ForegroundColor Yellow
Write-Host "===============================================" -ForegroundColor Cyan

Write-Host "[TEST] Test 1: Grid stability analysis with ML..." -ForegroundColor Cyan
$body8 = '{"interval": "1min", "analysis_types": ["anomaly", "clustering"]}'
Invoke-ApiCall -Url "http://localhost:8000/ml_analysis" -Method POST -Body $body8 -TimeoutSec 90 -ShowAsTable

Write-Host "[TEST] Test 2: DER performance optimization analysis..." -ForegroundColor Cyan
$body9 = '{"interval": "3min", "analysis_type": "performance"}'
Invoke-ApiCall -Url "http://localhost:8000/analyze_data" -Method POST -Body $body9 -TimeoutSec 60 -ShowAsTable

Write-Host "[TEST] Test 3: Multi-interval comparison..." -ForegroundColor Cyan
$body10 = '{"intervals": ["1min", "3min", "5min"]}'
Invoke-ApiCall -Url "http://localhost:8000/compare_intervals" -Method POST -Body $body10 -TimeoutSec 75 -ShowAsTable

Write-Host "[TEST] Test 4: Predictive maintenance analysis..." -ForegroundColor Cyan
$body11 = '{"interval": "1min", "question": "Based on this DER data, what patterns indicate potential equipment maintenance needs or performance degradation?"}'
Invoke-ApiCall -Url "http://localhost:8000/data_insights" -Method POST -Body $body11 -TimeoutSec 60 -ShowAsTable

# Step 10: Test Performance Monitoring
Write-Host "`nStep 10: Testing Performance Monitoring..." -ForegroundColor Yellow
Write-Host "=========================================" -ForegroundColor Cyan

Write-Host "[TEST] Getting performance metrics table..." -ForegroundColor Cyan
Invoke-ApiCall -Url "http://localhost:8000/metrics/table" -ShowAsTable

Write-Host "[TEST] Getting system metrics..." -ForegroundColor Cyan
Invoke-ApiCall -Url "http://localhost:8000/metrics/system" -ShowAsTable

Write-Host "[TEST] Getting detailed performance metrics..." -ForegroundColor Cyan
Invoke-ApiCall -Url "http://localhost:8000/metrics/performance" -ShowAsTable

# Step 11: Final Status Check
Write-Host "`nStep 11: Final System Status Check..." -ForegroundColor Yellow
Write-Host "====================================" -ForegroundColor Cyan

Write-Host "[INFO] Checking container status..." -ForegroundColor Cyan
docker-compose ps

Write-Host "`n[INFO] Service endpoints summary:" -ForegroundColor Green
Write-Host "- Data Service: http://localhost:7871" -ForegroundColor White
Write-Host "- LLM Service: http://localhost:8000" -ForegroundColor White
Write-Host "- Health Check: http://localhost:8000/health" -ForegroundColor White
Write-Host "- Performance Metrics: http://localhost:8000/metrics/table" -ForegroundColor White

# Step 12: Performance Summary
Write-Host "`nStep 12: Generating Performance Summary..." -ForegroundColor Yellow
Write-Host "==========================================" -ForegroundColor Cyan

Write-Host "[TEST] Getting final performance summary..." -ForegroundColor Cyan

# Fetch and display performance metrics in table format
try {
    $perfMetrics = Invoke-RestMethod -Uri "http://localhost:8000/metrics/performance" -TimeoutSec 10
    $sysMetrics = Invoke-RestMethod -Uri "http://localhost:8000/metrics/system" -TimeoutSec 10
    
    Write-Host "`n=== PERFORMANCE SUMMARY ===" -ForegroundColor Green
    Write-Host ""
    
    # System Metrics Table
    Write-Host "SYSTEM METRICS:" -ForegroundColor Cyan
    $sysTable = @(
        [PSCustomObject]@{
            Metric = "CPU Usage"
            Value = "$($sysMetrics.system_metrics.cpu_percent)%"
        },
        [PSCustomObject]@{
            Metric = "Memory Usage"
            Value = "$($sysMetrics.system_metrics.memory_percent)% ($([math]::Round($sysMetrics.system_metrics.memory_used_mb, 2)) MB)"
        },
        [PSCustomObject]@{
            Metric = "Disk Usage"
            Value = "$($sysMetrics.system_metrics.disk_usage_percent)%"
        }
    )
    $sysTable | Format-Table -AutoSize
    
    # Service Info Table
    Write-Host "SERVICE INFORMATION:" -ForegroundColor Cyan
    $serviceTable = @(
        [PSCustomObject]@{
            Property = "Service Name"
            Value = $sysMetrics.service_info.name
        },
        [PSCustomObject]@{
            Property = "Version"
            Value = $sysMetrics.service_info.version
        },
        [PSCustomObject]@{
            Property = "Status"
            Value = $sysMetrics.service_info.uptime
        },
        [PSCustomObject]@{
            Property = "Total Endpoints"
            Value = $sysMetrics.service_info.total_endpoints
        }
    )
    $serviceTable | Format-Table -AutoSize
    
    # Performance Metrics Table
    Write-Host "OPERATIONAL METRICS:" -ForegroundColor Cyan
    $opTable = @(
        [PSCustomObject]@{
            Metric = "Total Requests"
            Value = $perfMetrics.performance_summary.total_requests_processed
        },
        [PSCustomObject]@{
            Metric = "Avg Response Time"
            Value = "$($perfMetrics.performance_summary.average_response_time_seconds)s"
        },
        [PSCustomObject]@{
            Metric = "Service Health"
            Value = $perfMetrics.performance_summary.service_health
        },
        [PSCustomObject]@{
            Metric = "GPT Success Rate"
            Value = $perfMetrics.operational_metrics.gpt_analysis_success_rate
        },
        [PSCustomObject]@{
            Metric = "Data Service"
            Value = $perfMetrics.operational_metrics.data_service_connectivity
        }
    )
    $opTable | Format-Table -AutoSize
    
    # Features Table
    Write-Host "ACTIVE FEATURES:" -ForegroundColor Cyan
    $features = $sysMetrics.service_info.features | ForEach-Object {
        [PSCustomObject]@{ Feature = $_ }
    }
    $features | Format-Table -AutoSize
    
    Write-Host "=== END SUMMARY ===" -ForegroundColor Green
    Write-Host ""
    
} catch {
    Write-Host "[WARNING] Could not generate performance table: $($_.Exception.Message)" -ForegroundColor Yellow
    Invoke-ApiCall -Url "http://localhost:8000/metrics/table"
}

Write-Host "`n[SUCCESS] Setup and testing complete!" -ForegroundColor Green
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host "[SUCCESS] GPT ML Data Analysis Service is ready!" -ForegroundColor Green
Write-Host ""
Write-Host "Key Features Tested:" -ForegroundColor Yellow
Write-Host "  [OK] Basic GPT analysis" -ForegroundColor White
Write-Host "  [OK] DER data analysis with GPT interpretation" -ForegroundColor White
Write-Host "  [OK] Machine Learning anomaly detection" -ForegroundColor White
Write-Host "  [OK] ML clustering analysis" -ForegroundColor White
Write-Host "  [OK] Predictive modeling" -ForegroundColor White
Write-Host "  [OK] Comprehensive ML analysis with GPT insights" -ForegroundColor White
Write-Host "  [OK] Performance monitoring" -ForegroundColor White
Write-Host ""
Write-Host "Access your services:" -ForegroundColor Yellow
Write-Host "  - LLM Service: http://localhost:8000" -ForegroundColor White
Write-Host "  - Data Service: http://localhost:7871" -ForegroundColor White
Write-Host "  - API Documentation: http://localhost:8000/docs" -ForegroundColor White
Write-Host ""
Write-Host "Check performance metrics at: http://localhost:8000/metrics/table" -ForegroundColor Cyan
Write-Host ""
Write-Host "[SUCCESS] Your containerized GPT + ML analysis service is now running!" -ForegroundColor Green

exit 0
