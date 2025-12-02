# Enhanced status check script for Windows
# Checks Docker container status and service health

$ErrorActionPreference = "Continue"

# Color output functions
function Write-Header { 
    param([string]$Message)
    Write-Host "`n=== $Message ===" -ForegroundColor Cyan
}

function Write-Success { 
    param([string]$Message)
    Write-Host "[OK] $Message" -ForegroundColor Green 
}

function Write-Failure { 
    param([string]$Message)
    Write-Host "[X] $Message" -ForegroundColor Red 
}

# Check Docker Container Status
Write-Header "Docker Container Status"
try {
    $containers = docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
    if ($LASTEXITCODE -eq 0) {
        Write-Host $containers
        Write-Success "Docker containers retrieved successfully"
    } else {
        Write-Failure "Failed to retrieve Docker container status. Is Docker running?"
        exit 1
    }
} catch {
    Write-Failure "Error checking Docker status: $_"
    exit 1
}

# Test Services
Write-Header "Testing Services"

# Test Data Service (Port 7871)
try {
    $response = Invoke-WebRequest -Uri "http://localhost:7871/" -TimeoutSec 5 -UseBasicParsing
    if ($response.StatusCode -eq 200) {
        Write-Success "Data Service: Running (Port 7871)"
        
        # Parse and display service details if JSON
        try {
            $serviceData = $response.Content | ConvertFrom-Json
            if ($serviceData.message) {
                Write-Host "  Message: $($serviceData.message)" -ForegroundColor Gray
            }
            if ($serviceData.endpoints) {
                Write-Host "  Endpoints: $($serviceData.endpoints -join ', ')" -ForegroundColor Gray
            }
        } catch {
            # Ignore JSON parse errors
        }
    } else {
        Write-Failure "Data Service: Unexpected response code $($response.StatusCode)"
    }
} catch {
    Write-Failure "Data Service: Not responding. Check if the container is running."
    Write-Host "  Error: $($_.Exception.Message)" -ForegroundColor DarkGray
}

# Test LLM Service (Port 8000)
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8000/health" -TimeoutSec 5 -UseBasicParsing
    if ($response.StatusCode -eq 200) {
        Write-Success "LLM Service: Running (Port 8000)"
        
        # Parse and display health details if JSON
        try {
            $healthData = $response.Content | ConvertFrom-Json
            if ($healthData.status) {
                Write-Host "  Status: $($healthData.status)" -ForegroundColor Gray
            }
            if ($healthData.service) {
                Write-Host "  Service: $($healthData.service)" -ForegroundColor Gray
            }
        } catch {
            # Ignore JSON parse errors
        }
    } else {
        Write-Failure "LLM Service: Unexpected response code $($response.StatusCode)"
    }
} catch {
    Write-Failure "LLM Service: Not responding. Check if the container is running."
    Write-Host "  Error: $($_.Exception.Message)" -ForegroundColor DarkGray
}

# Recent Logs
Write-Header "Recent Container Logs"
try {
    Write-Host "`nLLM Service Logs (last 5 lines):" -ForegroundColor Yellow
    docker-compose logs --tail=5 llm_service 2>&1
    
    Write-Host "`nData Service Logs (last 5 lines):" -ForegroundColor Yellow
    docker-compose logs --tail=5 data_service 2>&1
    
    if ($LASTEXITCODE -ne 0) {
        Write-Failure "Failed to retrieve logs. Ensure docker-compose is installed and configured."
    }
} catch {
    Write-Failure "Error retrieving logs: $_"
}

# Summary
Write-Header "Status Check Complete"
Write-Host ""
Write-Host "Quick Commands:" -ForegroundColor Cyan
Write-Host "  View all logs:        docker-compose logs -f" -ForegroundColor Gray
Write-Host "  Restart services:     docker-compose restart" -ForegroundColor Gray
Write-Host "  Stop services:        docker-compose down" -ForegroundColor Gray
Write-Host "  Rebuild services:     docker-compose up -d --build" -ForegroundColor Gray
Write-Host ""
