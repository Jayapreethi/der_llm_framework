# Performance Monitoring Scripts

This folder contains scripts to monitor and display performance metrics for the DER LLM Framework.

## Available Scripts

### 1. `show_metrics.ps1` - Detailed Metrics Viewer
Displays comprehensive performance metrics in tabular format.

**Usage:**
```powershell
powershell -ExecutionPolicy Bypass -File show_metrics.ps1
```

**Output:**
- System Metrics (CPU, Memory, Disk)
- Service Information
- Operational Metrics
- Resource Usage
- Active Features
- Supported Intervals & Providers
- Cost Performance

---

### 2. `dashboard.ps1` - Live Dashboard
Interactive dashboard with visual progress bars and real-time metrics.

**Usage:**
```powershell
# Single view
powershell -ExecutionPolicy Bypass -File dashboard.ps1

# Continuous monitoring (refreshes every 5 seconds)
powershell -ExecutionPolicy Bypass -File dashboard.ps1 -Continuous

# Custom refresh interval (10 seconds)
powershell -ExecutionPolicy Bypass -File dashboard.ps1 -Continuous -RefreshSeconds 10
```

**Features:**
- Service status indicators
- Visual progress bars for system resources
- Performance metrics table
- Quick links to API endpoints

---

### 3. `setup.ps1` - Setup & Testing Script
Complete setup script with integrated performance summary at the end.

**Usage:**
```powershell
powershell -ExecutionPolicy Bypass -File setup.ps1
```

**Features:**
- Docker readiness check
- Container build & deployment
- Automated API testing
- Final performance summary in table format

---

## Quick Commands

### View Metrics Once
```powershell
.\show_metrics.ps1
```

### Live Dashboard
```powershell
.\dashboard.ps1 -Continuous
```

### Check Service Health
```powershell
Invoke-RestMethod -Uri "http://localhost:8000/health"
```

### Get Performance Table
```powershell
Invoke-RestMethod -Uri "http://localhost:8000/metrics/table"
```

### View Container Status
```powershell
docker-compose ps
```

---

## API Endpoints for Metrics

| Endpoint | Description |
|----------|-------------|
| `/health` | Service health check |
| `/metrics/table` | Performance metrics table |
| `/metrics/system` | System resource metrics |
| `/metrics/performance` | Detailed performance metrics |

---

## Troubleshooting

### Services Not Running
```powershell
# Check if containers are up
docker-compose ps

# Start services
docker-compose up -d

# View logs
docker-compose logs -f
```

### Cannot Connect to Metrics
Make sure services are running on the correct ports:
- LLM Service: http://localhost:8000
- Data Service: http://localhost:7871

### High Resource Usage
Monitor with:
```powershell
.\dashboard.ps1 -Continuous
```

Look for:
- CPU > 80% (RED indicator)
- Memory > 80% (RED indicator)  
- Disk > 90% (RED indicator)

---

## Examples

### Export Metrics to JSON
```powershell
Invoke-RestMethod -Uri "http://localhost:8000/metrics/performance" | ConvertTo-Json -Depth 10 | Out-File metrics.json
```

### Check Specific Metric
```powershell
$metrics = Invoke-RestMethod -Uri "http://localhost:8000/metrics/system"
Write-Host "CPU Usage: $($metrics.system_metrics.cpu_percent)%"
```

### Monitor in Loop
```powershell
while($true) {
    Clear-Host
    .\show_metrics.ps1
    Start-Sleep -Seconds 10
}
```

---

**Last Updated**: November 30, 2025
