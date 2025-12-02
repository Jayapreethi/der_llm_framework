# DER LLM Framework - Dashboard
# Comprehensive view of all services and metrics

param(
    [switch]$Continuous,
    [int]$RefreshSeconds = 5
)

function Show-Dashboard {
    Clear-Host
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    
    Write-Host "===============================================================================" -ForegroundColor Cyan
    Write-Host "          DER LLM FRAMEWORK - PERFORMANCE DASHBOARD                           " -ForegroundColor Cyan
    Write-Host "                 Last Updated: $timestamp                                     " -ForegroundColor Cyan
    Write-Host "===============================================================================" -ForegroundColor Cyan
    Write-Host ""
    
    try {
        # Fetch all metrics
        $health = Invoke-RestMethod -Uri "http://localhost:8000/health" -TimeoutSec 5
        $perfMetrics = Invoke-RestMethod -Uri "http://localhost:8000/metrics/performance" -TimeoutSec 5
        $sysMetrics = Invoke-RestMethod -Uri "http://localhost:8000/metrics/system" -TimeoutSec 5
        
        # Service Status
        Write-Host "SERVICE STATUS" -ForegroundColor Green
        Write-Host ("=" * 79) -ForegroundColor Green
        Write-Host ""
        
        $statusTable = @(
            [PSCustomObject]@{
                Service = "LLM Service"
                Status = $health.status.ToUpper()
                Version = $health.version
                URL = "http://localhost:8000"
            },
            [PSCustomObject]@{
                Service = "Data Service"
                Status = $(if($health.dependencies.dataservice_available) { "HEALTHY" } else { "DOWN" })
                Version = "N/A"
                URL = "http://localhost:7871"
            },
            [PSCustomObject]@{
                Service = "OpenAI API"
                Status = $(if($health.dependencies.openai_available) { "CONNECTED" } else { "NOT CONFIGURED" })
                Version = "N/A"
                URL = "api.openai.com"
            }
        )
        $statusTable | Format-Table -AutoSize
        
        # System Resources
        Write-Host "SYSTEM RESOURCES" -ForegroundColor Yellow
        Write-Host ("=" * 79) -ForegroundColor Yellow
        Write-Host ""
        
        $cpu = $sysMetrics.system_metrics.cpu_percent
        $mem = $sysMetrics.system_metrics.memory_percent
        $disk = $sysMetrics.system_metrics.disk_usage_percent
        
        Write-Host "  CPU:    " -NoNewline
        Show-Bar $cpu "%" 50 $(if($cpu -lt 80) { "Green" } else { "Red" })
        
        Write-Host "  Memory: " -NoNewline
        Show-Bar $mem "%" 50 $(if($mem -lt 80) { "Green" } else { "Red" })
        
        Write-Host "  Disk:   " -NoNewline
        Show-Bar $disk "%" 50 $(if($disk -lt 90) { "Green" } else { "Red" })
        
        Write-Host ""
        
        # Performance Metrics
        Write-Host "PERFORMANCE METRICS" -ForegroundColor Magenta
        Write-Host ("=" * 79) -ForegroundColor Magenta
        Write-Host ""
        
        $perfTable = @(
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
                Value = $perfMetrics.performance_summary.service_health.ToUpper()
            },
            [PSCustomObject]@{
                Metric = "GPT Success Rate"
                Value = $perfMetrics.operational_metrics.gpt_analysis_success_rate
            }
        )
        $perfTable | Format-Table -AutoSize
        
        # Active Operations
        Write-Host "RESOURCE USAGE" -ForegroundColor Blue
        Write-Host ("=" * 79) -ForegroundColor Blue
        Write-Host ""
        
        $resourceTable = @(
            [PSCustomObject]@{
                Resource = "GPT Requests"
                Count = $sysMetrics.resource_usage.gpt_requests_made
            },
            [PSCustomObject]@{
                Resource = "Cost Calculations"
                Count = $sysMetrics.resource_usage.cost_calculations_performed
            },
            [PSCustomObject]@{
                Resource = "Total Operations"
                Count = $sysMetrics.resource_usage.total_operations
            }
        )
        $resourceTable | Format-Table -AutoSize
        
        # Quick Links
        Write-Host "QUICK LINKS" -ForegroundColor Cyan
        Write-Host ("=" * 79) -ForegroundColor Cyan
        Write-Host ""
        Write-Host "  API Docs:        http://localhost:8000/docs" -ForegroundColor White
        Write-Host "  Health Check:    http://localhost:8000/health" -ForegroundColor White
        Write-Host "  Metrics:         http://localhost:8000/metrics/table" -ForegroundColor White
        Write-Host "  Data Service:    http://localhost:7871/data/1min" -ForegroundColor White
        Write-Host ""
        
        if ($Continuous) {
            Write-Host "Press Ctrl+C to exit. Refreshing in $RefreshSeconds seconds..." -ForegroundColor Gray
        }
        
    } catch {
        Write-Host "[ERROR] Cannot connect to services!" -ForegroundColor Red
        Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "Make sure services are running with: docker-compose ps" -ForegroundColor White
        
        if (-not $Continuous) {
            exit 1
        }
    }
}

function Show-Bar {
    param(
        [double]$Value,
        [string]$Unit,
        [int]$Width,
        [string]$Color = "Green"
    )
    
    $filled = [math]::Round(($Value / 100) * $Width)
    $empty = $Width - $filled
    
    $bar = ""
    $bar += "[" 
    $bar += "#" * $filled
    $bar += "-" * $empty
    $bar += "]"
    
    Write-Host $bar -NoNewline -ForegroundColor $Color
    Write-Host " $([math]::Round($Value, 1))$Unit" -ForegroundColor White
}

# Main execution
if ($Continuous) {
    while ($true) {
        Show-Dashboard
        Start-Sleep -Seconds $RefreshSeconds
    }
} else {
    Show-Dashboard
}
