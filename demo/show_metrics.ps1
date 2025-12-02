# Performance Metrics Viewer
# Displays service metrics in tabular format

$ErrorActionPreference = "Stop"

Write-Host "`n=== DER LLM FRAMEWORK - PERFORMANCE METRICS ===" -ForegroundColor Cyan
Write-Host "Fetching metrics from http://localhost:8000..." -ForegroundColor Gray
Write-Host ""

try {
    # Fetch metrics
    $perfMetrics = Invoke-RestMethod -Uri "http://localhost:8000/metrics/performance" -TimeoutSec 10
    $sysMetrics = Invoke-RestMethod -Uri "http://localhost:8000/metrics/system" -TimeoutSec 10
    
    # System Metrics Table
    Write-Host "SYSTEM METRICS:" -ForegroundColor Green
    $sysTable = @(
        [PSCustomObject]@{
            Metric = "CPU Usage"
            Value = "$($sysMetrics.system_metrics.cpu_percent)%"
            Status = $(if($sysMetrics.system_metrics.cpu_percent -lt 80) { "OK" } else { "HIGH" })
        },
        [PSCustomObject]@{
            Metric = "Memory Usage"
            Value = "$($sysMetrics.system_metrics.memory_percent)% ($([math]::Round($sysMetrics.system_metrics.memory_used_mb, 2)) MB)"
            Status = $(if($sysMetrics.system_metrics.memory_percent -lt 80) { "OK" } else { "HIGH" })
        },
        [PSCustomObject]@{
            Metric = "Disk Usage"
            Value = "$($sysMetrics.system_metrics.disk_usage_percent)%"
            Status = $(if($sysMetrics.system_metrics.disk_usage_percent -lt 90) { "OK" } else { "HIGH" })
        }
    )
    $sysTable | Format-Table -AutoSize
    
    # Service Info Table
    Write-Host "SERVICE INFORMATION:" -ForegroundColor Green
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
    Write-Host "OPERATIONAL METRICS:" -ForegroundColor Green
    $opTable = @(
        [PSCustomObject]@{
            Metric = "Total Requests Processed"
            Value = $perfMetrics.performance_summary.total_requests_processed
        },
        [PSCustomObject]@{
            Metric = "Average Response Time"
            Value = "$($perfMetrics.performance_summary.average_response_time_seconds) seconds"
        },
        [PSCustomObject]@{
            Metric = "Service Health"
            Value = $perfMetrics.performance_summary.service_health.ToUpper()
        },
        [PSCustomObject]@{
            Metric = "GPT Analysis Success Rate"
            Value = $perfMetrics.operational_metrics.gpt_analysis_success_rate
        },
        [PSCustomObject]@{
            Metric = "Data Service Connectivity"
            Value = $perfMetrics.operational_metrics.data_service_connectivity.ToUpper()
        },
        [PSCustomObject]@{
            Metric = "Cost Calculation Accuracy"
            Value = $perfMetrics.operational_metrics.cost_calculation_accuracy
        }
    )
    $opTable | Format-Table -AutoSize
    
    # Resource Usage Table
    Write-Host "RESOURCE USAGE:" -ForegroundColor Green
    $resourceTable = @(
        [PSCustomObject]@{
            Resource = "GPT Requests Made"
            Count = $sysMetrics.resource_usage.gpt_requests_made
        },
        [PSCustomObject]@{
            Resource = "Cost Calculations Performed"
            Count = $sysMetrics.resource_usage.cost_calculations_performed
        },
        [PSCustomObject]@{
            Resource = "Total Operations"
            Count = $sysMetrics.resource_usage.total_operations
        }
    )
    $resourceTable | Format-Table -AutoSize
    
    # Active Features Table
    Write-Host "ACTIVE FEATURES:" -ForegroundColor Green
    $features = $sysMetrics.service_info.features | ForEach-Object {
        [PSCustomObject]@{ Feature = $_ }
    }
    $features | Format-Table -AutoSize
    
    # Active Intervals Table
    Write-Host "SUPPORTED DATA INTERVALS:" -ForegroundColor Green
    $intervals = $sysMetrics.resource_usage.active_intervals | ForEach-Object {
        [PSCustomObject]@{ Interval = $_ }
    }
    $intervals | Format-Table -AutoSize
    
    # Cloud Providers Table
    Write-Host "SUPPORTED CLOUD PROVIDERS:" -ForegroundColor Green
    $providers = $perfMetrics.operational_metrics.supported_cloud_providers | ForEach-Object {
        [PSCustomObject]@{ Provider = $_.ToUpper() }
    }
    $providers | Format-Table -AutoSize
    
    # Cost Performance Summary
    Write-Host "COST PERFORMANCE:" -ForegroundColor Green
    $costTable = @(
        [PSCustomObject]@{
            Metric = "Total Cost Calculations"
            Value = $perfMetrics.cost_performance.total_cost_calculations
        },
        [PSCustomObject]@{
            Metric = "Avg Cost Per Analysis"
            Value = "$($perfMetrics.cost_performance.average_cost_per_analysis)"
        },
        [PSCustomObject]@{
            Metric = "Cheapest Provider"
            Value = $perfMetrics.cost_performance.cheapest_provider_overall.ToUpper()
        }
    )
    $costTable | Format-Table -AutoSize
    
    Write-Host "=== END METRICS ===" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Last Updated: $($perfMetrics.timestamp)" -ForegroundColor Gray
    Write-Host ""
    
} catch {
    Write-Host "[ERROR] Failed to fetch metrics: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ""
    Write-Host "Make sure the services are running:" -ForegroundColor Yellow
    Write-Host "  docker-compose ps" -ForegroundColor White
    Write-Host ""
    Write-Host "If services are down, start them with:" -ForegroundColor Yellow
    Write-Host "  docker-compose up -d" -ForegroundColor White
    Write-Host ""
    exit 1
}
