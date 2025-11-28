# PowerShell Setup Script for GPT ML Data Analysis Service
# Version: 3.0.0 - Windows Compatible
# Focus: GPT analysis and ML-based DER data analysis

# Set error action preference
$ErrorActionPreference = "Stop"

Write-Host "🚀 Starting GPT ML Data Analysis Service Setup..." -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan

# Step 0: Export API Tokens
Write-Host "`nStep 0: Setting up API tokens..." -ForegroundColor Yellow
$env:OPENAI_API_KEY = "PUT_YOUR_OPENAI_API_KEY_HERE"
Write-Host "OPENAI_API_KEY: $env:OPENAI_API_KEY" -ForegroundColor Green

# Step 1: Environment Check
Write-Host "`nStep 1: Checking environment..." -ForegroundColor Yellow

# Check for docker-compose
if (-not (Get-Command docker-compose -ErrorAction SilentlyContinue)) {
    Write-Host "❌ docker-compose not found! Please install Docker Desktop for Windows." -ForegroundColor Red
    exit 1
}

# Check for curl (built into Windows 10+)
if (-not (Get-Command curl.exe -ErrorAction SilentlyContinue)) {
    Write-Host "⚠️  curl not found! Using Invoke-WebRequest instead." -ForegroundColor Yellow
    $useCurl = $false
} else {
    $useCurl = $true
}

Write-Host "✅ Environment check passed." -ForegroundColor Green

# Step 2: Docker Compose Build (No Cache)
Write-Host "`nStep 2: Building Docker containers..." -ForegroundColor Yellow

Write-Host "Stopping existing containers..." -ForegroundColor Cyan
docker-compose down 2>&1 | Out-Null

Write-Host "Removing existing Docker containers..." -ForegroundColor Cyan
docker-compose rm -f 2>&1 | Out-Null

Write-Host "Cleaning up Docker system..." -ForegroundColor Cyan
docker system prune -f
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Docker system prune failed! Please check your Docker setup." -ForegroundColor Red
    exit 1
}

Write-Host "Building Docker containers with --no-cache..." -ForegroundColor Cyan
docker-compose build --no-cache --progress=plain
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Docker build failed! Please check the Dockerfile and dependencies." -ForegroundColor Red
    exit 1
}

Write-Host "Final system cleanup..." -ForegroundColor Cyan
docker system prune -f

# Step 3: Docker Compose Up
Write-Host "`nStep 3: Starting Docker containers..." -ForegroundColor Yellow
docker-compose up -d
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Docker Compose up failed! Please check your docker-compose.yml file." -ForegroundColor Red
    exit 1
}

# Step 4: Wait for Containers to Start
Write-Host "`nStep 4: Waiting for containers to initialize..." -ForegroundColor Yellow
Write-Host "Waiting 20 seconds for services to fully start..." -ForegroundColor Cyan
Start-Sleep -Seconds 20

# Helper function for API calls
function Invoke-ApiCall {
    param(
        [string]$Url,
        [string]$Method = "GET",
        [string]$Body = $null,
        [int]$TimeoutSec = 10
    )
    
    try {
        if ($useCurl) {
            if ($Method -eq "POST" -and $Body) {
                curl.exe -X POST $Url -H "Content-Type: application/json" -d $Body --max-time $TimeoutSec
            } else {
                curl.exe -X GET $Url -H "Content-Type: application/json" --max-time $TimeoutSec
            }
        } else {
            $headers = @{"Content-Type"="application/json"}
            if ($Method -eq "POST" -and $Body) {
                $response = Invoke-RestMethod -Uri $Url -Method POST -Headers $headers -Body $Body -TimeoutSec $TimeoutSec
            } else {
                $response = Invoke-RestMethod -Uri $Url -Method GET -Headers $headers -TimeoutSec $TimeoutSec
            }
            $response | ConvertTo-Json -Depth 10
        }
        Write-Host ""
    } catch {
        Write-Host "⚠️  Request failed: $($_.Exception.Message)" -ForegroundColor Yellow
    }
}

# Step 5: Test Data Service Endpoints
Write-Host "`nStep 5: Testing Data Service endpoints..." -ForegroundColor Yellow
Write-Host "=========================================" -ForegroundColor Cyan

Write-Host "🔍 Testing data service root endpoint..." -ForegroundColor Cyan
Invoke-ApiCall -Url "http://localhost:7871/"

Write-Host "📊 Fetching 1min aggregated DER data..." -ForegroundColor Cyan
Invoke-ApiCall -Url "http://localhost:7871/data/1min" -TimeoutSec 15

Write-Host "📊 Fetching 3min aggregated DER data..." -ForegroundColor Cyan
Invoke-ApiCall -Url "http://localhost:7871/data/3min" -TimeoutSec 15

Write-Host "📊 Fetching 5min aggregated DER data..." -ForegroundColor Cyan
Invoke-ApiCall -Url "http://localhost:7871/data/5min" -TimeoutSec 15

# Step 6: Test LLM Service Basic Endpoints
Write-Host "`nStep 6: Testing LLM Service basic endpoints..." -ForegroundColor Yellow
Write-Host "==============================================" -ForegroundColor Cyan

Write-Host "🔍 Testing LLM service root endpoint..." -ForegroundColor Cyan
Invoke-ApiCall -Url "http://localhost:8000/"

Write-Host "🏥 Testing health check endpoint..." -ForegroundColor Cyan
Invoke-ApiCall -Url "http://localhost:8000/health"

# Step 7: Test GPT Analysis Endpoints
Write-Host "`nStep 7: Testing GPT Analysis endpoints..." -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Cyan

Write-Host "🤖 Testing basic GPT endpoint..." -ForegroundColor Cyan
$body1 = '{"prompt": "What is distributed energy resource (DER) analysis?"}'
Invoke-ApiCall -Url "http://localhost:8000/query_gpt" -Method POST -Body $body1 -TimeoutSec 30

Write-Host "📊 Testing DER data analysis endpoint..." -ForegroundColor Cyan
$body2 = '{"interval": "1min", "analysis_type": "summary"}'
Invoke-ApiCall -Url "http://localhost:8000/analyze_data" -Method POST -Body $body2 -TimeoutSec 45

Write-Host "🔍 Testing data insights endpoint..." -ForegroundColor Cyan
$body3 = '{"question": "What are the key performance indicators in this DER data?", "interval": "1min"}'
Invoke-ApiCall -Url "http://localhost:8000/data_insights" -Method POST -Body $body3 -TimeoutSec 45

# Step 8: Test Machine Learning Analysis Endpoints
Write-Host "`nStep 8: Testing Machine Learning Analysis endpoints..." -ForegroundColor Yellow
Write-Host "====================================================" -ForegroundColor Cyan

Write-Host "🔬 Testing anomaly detection..." -ForegroundColor Cyan
$body4 = '{"interval": "1min"}'
Invoke-ApiCall -Url "http://localhost:8000/detect_anomalies" -Method POST -Body $body4 -TimeoutSec 60

Write-Host "🎯 Testing clustering analysis..." -ForegroundColor Cyan
$body5 = '{"interval": "1min", "n_clusters": 3}'
Invoke-ApiCall -Url "http://localhost:8000/cluster_analysis" -Method POST -Body $body5 -TimeoutSec 60

Write-Host "📈 Testing predictive analysis..." -ForegroundColor Cyan
$body6 = '{"interval": "1min"}'
Invoke-ApiCall -Url "http://localhost:8000/predictive_analysis" -Method POST -Body $body6 -TimeoutSec 60

Write-Host "🔬 Testing comprehensive ML analysis..." -ForegroundColor Cyan
$body7 = '{"interval": "1min"}'
Invoke-ApiCall -Url "http://localhost:8000/comprehensive_ml_analysis" -Method POST -Body $body7 -TimeoutSec 90

# Step 9: Test Advanced GPT + ML Integration
Write-Host "`nStep 9: Testing Advanced GPT + ML Integration..." -ForegroundColor Yellow
Write-Host "===============================================" -ForegroundColor Cyan

Write-Host "⚡ Test 1: Grid stability analysis with ML..." -ForegroundColor Cyan
$body8 = '{"interval": "1min", "analysis_types": ["anomaly", "clustering"]}'
Invoke-ApiCall -Url "http://localhost:8000/ml_analysis" -Method POST -Body $body8 -TimeoutSec 90

Write-Host "🔋 Test 2: DER performance optimization analysis..." -ForegroundColor Cyan
$body9 = '{"interval": "3min", "analysis_type": "performance"}'
Invoke-ApiCall -Url "http://localhost:8000/analyze_data" -Method POST -Body $body9 -TimeoutSec 60

Write-Host "📊 Test 3: Multi-interval comparison..." -ForegroundColor Cyan
$body10 = '{"intervals": ["1min", "3min", "5min"]}'
Invoke-ApiCall -Url "http://localhost:8000/compare_intervals" -Method POST -Body $body10 -TimeoutSec 75

Write-Host "🔍 Test 4: Predictive maintenance analysis..." -ForegroundColor Cyan
$body11 = '{"interval": "1min", "question": "Based on this DER data, what patterns indicate potential equipment maintenance needs or performance degradation?"}'
Invoke-ApiCall -Url "http://localhost:8000/data_insights" -Method POST -Body $body11 -TimeoutSec 60

# Step 10: Test Performance Monitoring
Write-Host "`nStep 10: Testing Performance Monitoring..." -ForegroundColor Yellow
Write-Host "=========================================" -ForegroundColor Cyan

Write-Host "📊 Getting performance metrics table..." -ForegroundColor Cyan
Invoke-ApiCall -Url "http://localhost:8000/metrics/table"

Write-Host "💻 Getting system metrics..." -ForegroundColor Cyan
Invoke-ApiCall -Url "http://localhost:8000/metrics/system"

Write-Host "📈 Getting detailed performance metrics..." -ForegroundColor Cyan
Invoke-ApiCall -Url "http://localhost:8000/metrics/performance"

# Step 11: Final Status Check
Write-Host "`nStep 11: Final System Status Check..." -ForegroundColor Yellow
Write-Host "====================================" -ForegroundColor Cyan

Write-Host "🔍 Checking container status..." -ForegroundColor Cyan
docker-compose ps

Write-Host "`n📊 Service endpoints summary:" -ForegroundColor Green
Write-Host "- Data Service: http://localhost:7871" -ForegroundColor White
Write-Host "- LLM Service: http://localhost:8000" -ForegroundColor White
Write-Host "- Health Check: http://localhost:8000/health" -ForegroundColor White
Write-Host "- Performance Metrics: http://localhost:8000/metrics/table" -ForegroundColor White

# Step 12: Performance Summary
Write-Host "`nStep 12: Generating Performance Summary..." -ForegroundColor Yellow
Write-Host "==========================================" -ForegroundColor Cyan

Write-Host "🎯 Getting final performance summary..." -ForegroundColor Cyan
Invoke-ApiCall -Url "http://localhost:8000/metrics/table"

Write-Host "`n✅ Setup and testing complete!" -ForegroundColor Green
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host "🎉 GPT ML Data Analysis Service is ready!" -ForegroundColor Green
Write-Host ""
Write-Host "🔍 Key Features Tested:" -ForegroundColor Yellow
Write-Host "  ✓ Basic GPT analysis" -ForegroundColor White
Write-Host "  ✓ DER data analysis with GPT interpretation" -ForegroundColor White
Write-Host "  ✓ Machine Learning anomaly detection" -ForegroundColor White
Write-Host "  ✓ ML clustering analysis" -ForegroundColor White
Write-Host "  ✓ Predictive modeling" -ForegroundColor White
Write-Host "  ✓ Comprehensive ML analysis with GPT insights" -ForegroundColor White
Write-Host "  ✓ Performance monitoring" -ForegroundColor White
Write-Host ""
Write-Host "🔗 Access your services:" -ForegroundColor Yellow
Write-Host "  • LLM Service: http://localhost:8000" -ForegroundColor White
Write-Host "  • Data Service: http://localhost:7871" -ForegroundColor White
Write-Host "  • API Documentation: http://localhost:8000/docs" -ForegroundColor White
Write-Host ""
Write-Host "📊 Check performance metrics at: http://localhost:8000/metrics/table" -ForegroundColor Cyan
Write-Host ""
Write-Host "🚀 Your containerized GPT + ML analysis service is now running!" -ForegroundColor Green

exit 0
