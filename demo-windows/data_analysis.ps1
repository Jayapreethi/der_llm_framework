# Data Analysis Tests for DER LLM Framework
# Tests various GPT-powered analysis scenarios

$ErrorActionPreference = "Continue"

# Configuration
$LLM_SERVICE = "http://localhost:8000"
$MODEL = "gpt"

# Color output functions
function Write-TestHeader { 
    param([string]$TestNumber, [string]$Title)
    Write-Host "`n======================================" -ForegroundColor Cyan
    Write-Host "Test $TestNumber : $Title" -ForegroundColor Yellow
    Write-Host "======================================" -ForegroundColor Cyan
}

function Write-Info { 
    param([string]$Message)
    Write-Host $Message -ForegroundColor Gray
}

function Invoke-AnalysisTest {
    param(
        [string]$Interval,
        [string]$Question,
        [string]$TestName
    )
    
    $body = @{
        interval = $Interval
        question = $Question
    } | ConvertTo-Json
    
    Write-Info "Sending request..."
    Write-Info "Interval: $Interval"
    Write-Info "Question: $Question`n"
    
    try {
        $response = Invoke-RestMethod -Uri "$LLM_SERVICE/data_insights" `
            -Method Post `
            -ContentType "application/json" `
            -Body $body `
            -TimeoutSec 30
        
        Write-Host "Response:" -ForegroundColor Green
        $response | ConvertTo-Json -Depth 5 | Write-Host
        Write-Host "`n[SUCCESS] $TestName completed" -ForegroundColor Green
        return $true
    } catch {
        Write-Host "[ERROR] $TestName failed" -ForegroundColor Red
        Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
        if ($_.Exception.Response) {
            Write-Host "Status Code: $($_.Exception.Response.StatusCode.Value__)" -ForegroundColor Red
        }
        return $false
    }
}

# Main execution
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  DER Data Analysis Test Suite" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Cyan
Write-Info "Target: $LLM_SERVICE"
Write-Info "Model: $MODEL"
Write-Host ""

$testResults = @()

# Test 1: Grid stability analysis
Write-TestHeader "1" "Grid Stability Analysis"
$result = Invoke-AnalysisTest `
    -Interval "1min" `
    -Question "Analyze this data for grid stability indicators. Look for frequency variations, voltage irregularities, and power quality issues." `
    -TestName "Grid Stability Analysis"
$testResults += @{ Test = "Grid Stability"; Success = $result }

Start-Sleep -Seconds 2

# Test 2: Renewable energy integration
Write-TestHeader "2" "Renewable Energy Integration"
$result = Invoke-AnalysisTest `
    -Interval "3min" `
    -Question "Assuming this is renewable energy data, analyze the variability patterns and suggest grid integration strategies." `
    -TestName "Renewable Energy Integration"
$testResults += @{ Test = "Renewable Integration"; Success = $result }

Start-Sleep -Seconds 2

# Test 3: Demand response opportunities
Write-TestHeader "3" "Demand Response Opportunities"
$result = Invoke-AnalysisTest `
    -Interval "5min" `
    -Question "Identify potential demand response opportunities and times when energy consumption could be shifted for better grid balance." `
    -TestName "Demand Response Analysis"
$testResults += @{ Test = "Demand Response"; Success = $result }

Start-Sleep -Seconds 2

# Test 4: Predictive maintenance indicators
Write-TestHeader "4" "Predictive Maintenance Indicators"
$result = Invoke-AnalysisTest `
    -Interval "1min" `
    -Question "Look for patterns that might indicate equipment maintenance needs or performance degradation in this energy system." `
    -TestName "Predictive Maintenance"
$testResults += @{ Test = "Predictive Maintenance"; Success = $result }

# Summary Report
Write-Host "`n======================================" -ForegroundColor Cyan
Write-Host "  Test Summary" -ForegroundColor Yellow
Write-Host "======================================" -ForegroundColor Cyan

$passCount = ($testResults | Where-Object { $_.Success -eq $true }).Count
$failCount = ($testResults | Where-Object { $_.Success -eq $false }).Count

foreach ($result in $testResults) {
    $status = if ($result.Success) { "[PASS]" } else { "[FAIL]" }
    $color = if ($result.Success) { "Green" } else { "Red" }
    Write-Host "$status $($result.Test)" -ForegroundColor $color
}

Write-Host "`nTotal Tests: $($testResults.Count)" -ForegroundColor Cyan
Write-Host "Passed: $passCount" -ForegroundColor Green
Write-Host "Failed: $failCount" -ForegroundColor Red
Write-Host ""

if ($failCount -gt 0) {
    Write-Host "Note: Some tests failed. This may be due to:" -ForegroundColor Yellow
    Write-Host "  - Missing or invalid OPENAI_API_KEY" -ForegroundColor Gray
    Write-Host "  - Service not running" -ForegroundColor Gray
    Write-Host "  - Network connectivity issues" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Check service status with: .\check_status.ps1" -ForegroundColor Cyan
}
